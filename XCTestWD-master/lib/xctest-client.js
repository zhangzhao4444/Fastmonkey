'use strict';

const url = require('url');
const path = require('path');
const iOSUtils = require('ios-utils');
const EventEmitter = require('events');
const childProcess = require('child_process');

const _ = require('./helper');
const pkg = require('../package');
const XCProxy = require('./proxy');
const logger = require('./logger');
const XCTestWD = require('./xctestwd');

const {
  detectPort
} = _;
const TEST_URL = pkg.site;
const projectPath = XCTestWD.projectPath;
const SERVER_URL_REG = XCTestWD.SERVER_URL_REG;
const simulatorLogFlag = XCTestWD.simulatorLogFlag;

class XCTest extends EventEmitter {
  constructor(options) {
    super();
    this.proxy = null;
    this.capabilities = null;
    this.sessionId = null;
    this.device = null;
    this.deviceLogProc = null;
    this.runnerProc = null;
    this.iproxyProc = null;
    Object.assign(this, {
      proxyHost: '127.0.0.1',
      proxyPort: 8001,
      urlBase: 'wd/hub'
    }, options || {});
    this.init();
  }

  init() {
    this.checkProjectPath();
    process.on('uncaughtException', (e) => {
      logger.error(`Uncaught Exception: ${e.stack}`);
      this.stop();
      process.exit(1);
    });
    process.on('exit', () => {
      this.stop();
    });
  }

  checkProjectPath() {
    if (_.isExistedDir(projectPath)) {
      logger.debug(`project path: ${projectPath}`);
    } else {
      logger.error('project path not found');
    }
  }

  configUrl(str) {
    const urlObj = url.parse(str);
    this.proxyHost = urlObj.hostname;
    this.proxyPort = urlObj.port;
  }

  initProxy() {
    this.proxy = new XCProxy({
      proxyHost: this.proxyHost,
      proxyPort: this.proxyPort,
      urlBase: this.urlBase
    });
  }

  * startSimLog() {
    const logPath = yield this.startBootstrap();
    const logDir = path.resolve(logPath);
    return _.retry(() => {
      return new Promise((resolve, reject) => {
        const logTxtFile = path.join(logDir, '..', 'StandardOutputAndStandardError.txt');
        logger.info(`Read simulator log at: ${logTxtFile}`);

        if (!_.isExistedFile(logTxtFile)) {
          return reject();
        }
        let args = `-f -n 0 ${logTxtFile}`.split(' ');
        var proc = childProcess.spawn('tail', args, {});
        this.deviceLogProc = proc;

        proc.stderr.setEncoding('utf8');
        proc.stdout.setEncoding('utf8');

        proc.stdout.on('data', data => {

          // avoid logout long data such as bitmap
          if (data.length <= 300 && logger.debugMode) {
            // logger.debug(data);
          }

          let match = SERVER_URL_REG.exec(data);
          if (match) {
            const url = match[1];
            if (url.startsWith('http://')) {
              this.configUrl(url);
              resolve();
            }
          }
        });

        proc.stderr.on('data', data => {
          logger.debug(data);
        });

        proc.stdout.on('error', (err) => {
          logger.warn(`simulator log process error with ${err}`);
        });

        proc.on('exit', (code, signal) => {
          logger.warn(`simulator log process exit with code: ${code}, signal: ${signal}`);
          reject();
        });
      });
    }, 1000, Infinity);
  }

  * startDeviceLog() {
    yield this.startBootstrap();
    var proc = childProcess.spawn(iOSUtils.devicelog.binPath, [this.device.deviceId], {});
    this.deviceLogProc = proc;

    proc.stderr.setEncoding('utf8');
    proc.stdout.setEncoding('utf8');

    return new Promise((resolve, reject) => {
      proc.stdout.on('data', data => {

        // avoid logout long data such as bitmap
        if (data.length <= 300 && logger.debugMode) {
          logger.debug(data);
        }

        let match = SERVER_URL_REG.exec(data);
        if (match) {
          const url = match[1];
          if (url.startsWith('http://')) {
            this.configUrl(url);
            resolve();
          }
        }
      });

      proc.stderr.on('data', data => {
        logger.debug(data);
      });

      proc.stdout.on('error', (err) => {
        logger.warn(`devicelog error with ${err}`);
      });

      proc.on('exit', (code, signal) => {
        logger.warn(`devicelog exit with code: ${code}, signal: ${signal}`);
        reject();
      });
    });
  }

  * startBootstrap() {
    return new Promise((resolve, reject) => {
      logger.info(`XCTestWD version: ${XCTestWD.version}`);

      var args = `clean test -project ${XCTestWD.projectPath} -scheme XCTestWDUITests -destination id=${this.device.deviceId} XCTESTWD_PORT=${this.proxyPort}`.split(' ');
      var env = _.merge({}, process.env, {
        XCTESTWD_PORT: this.proxyPort
      });

      var proc = childProcess.spawn('xcodebuild', args, {
        env: env
      });
      this.runnerProc = proc;
      proc.stderr.setEncoding('utf8');
      proc.stdout.setEncoding('utf8');

      proc.stdout.on('data', data => {
        // logger.debug(data);
      });

      proc.stderr.on('data', data => {
        // logger.debug(data);

        if (~data.indexOf(simulatorLogFlag)) {
          const list = data.split(simulatorLogFlag);
          const res = list[1].trim();
          resolve(res);
        } else {
          logger.debug(`please check project: ${projectPath}`);
        }
      });

      proc.stdout.on('error', (err) => {
        logger.warn(`xctest client error with ${err}`);
        logger.debug(`please check project: ${projectPath}`);
      });

      proc.on('exit', (code, signal) => {
        this.stop();
        logger.warn(`xctest client exit with code: ${code}, signal: ${signal}`);
      });

    });
  }

  * startIproxy() {
    let args = [this.proxyPort, this.proxyPort, this.device.deviceId];

    const IOS_USBMUXD_IPROXY = 'iproxy';
    const binPath = yield _.exec(`which ${IOS_USBMUXD_IPROXY}`);

    var proc = childProcess.spawn(binPath, args);

    this.iproxyProc = proc;
    proc.stderr.setEncoding('utf8');
    proc.stdout.setEncoding('utf8');

    proc.stdout.on('data', () => {
    });

    proc.stderr.on('data', () => {
      // logger.debug(data);
    });

    proc.stdout.on('error', (err) => {
      logger.warn(`${IOS_USBMUXD_IPROXY} error with ${err}`);
    });

    proc.on('exit', (code, signal) => {
      logger.warn(`${IOS_USBMUXD_IPROXY} exit with code: ${code}, signal: ${signal}`);
    });
  }

  * start(caps) {
    try {
      this.proxyPort = yield detectPort(this.proxyPort);

      this.capabilities = caps;
      const xcodeVersion = yield iOSUtils.getXcodeVersion();

      logger.debug(`xcode version: ${xcodeVersion}`);

      var deviceInfo = iOSUtils.getDeviceInfo(this.device.deviceId);

      if (deviceInfo.isRealIOS) {
        yield this.startDeviceLog();
        yield this.startIproxy();
      } else {
        yield this.startSimLog();
      }

      logger.info(`${pkg.name} start with port: ${this.proxyPort}`);

      this.initProxy();

      if (caps.desiredCapabilities.browserName === 'Safari') {
        var promise = this.proxy.send(`/${this.urlBase}/session`, 'POST', {
          desiredCapabilities: {
            bundleId: 'com.apple.mobilesafari'
          }
        });
        return yield Promise.all([this.device.openURL(TEST_URL), promise]);
      } else {
        return yield this.proxy.send(`/${this.urlBase}/session`, 'POST', caps);
      }
    } catch (err) {
      logger.debug(`Fail to start xctest: ${err}`);
      this.stop();
      throw err;
    }
  }

  stop() {
    if (this.deviceLogProc) {
      logger.debug(`killing deviceLogProc pid: ${this.deviceLogProc.pid}`);
      this.deviceLogProc.kill('SIGKILL');
      this.deviceLogProc = null;
    }
    if (this.runnerProc) {
      logger.debug(`killing runnerProc pid: ${this.runnerProc.pid}`);
      this.runnerProc.kill('SIGKILL');
      this.runnerProc = null;
    }

    if (this.iproxyProc) {
      logger.debug(`killing iproxyProc pid: ${this.iproxyProc.pid}`);
      this.iproxyProc.kill('SIGKILL');
      this.iproxyProc = null;
    }
  }

  sendCommand(url, method, body) {
    return this.proxy.send(url, method, body);
  }
}

module.exports = XCTest;
module.exports.XCTestWD = XCTestWD;
