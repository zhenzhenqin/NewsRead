import fs from '@ohos.file.fs';
import { Context } from '@kit.AbilityKit';

class Logger {
  private static logPath: string = '';
  private static context: Context | null = null;

  static setContext(ctx: Context): void {
    Logger.context = ctx;
    Logger.logPath = ctx.filesDir + '/app_log.txt';
    // 清空旧日志：用 CREATE 模式打开会截断文件
    try {
      let file = fs.openSync(Logger.logPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      fs.closeSync(file);
    } catch (e) {
      // 忽略
    }
    Logger.write('INFO', '=== App Log Start ===');
  }

  private static write(level: string, msg: string): void {
    if (!Logger.logPath) {
      return;
    }
    try {
      const now = new Date();
      const time = now.getHours().toString().padStart(2, '0') + ':' +
        now.getMinutes().toString().padStart(2, '0') + ':' +
        now.getSeconds().toString().padStart(2, '0') + '.' +
        now.getMilliseconds().toString().padStart(3, '0');
      const line = '[' + time + '] ' + level + ' ' + msg + '\n';

      let file = fs.openSync(Logger.logPath, fs.OpenMode.CREATE | fs.OpenMode.APPEND);
      fs.writeSync(file.fd, line);
      fs.closeSync(file);
    } catch (e) {
      // 写日志失败不影响业务
    }
  }

  static info(msg: string): void {
    Logger.write('INFO', msg);
    console.log(msg);
  }

  static error(msg: string): void {
    Logger.write('ERROR', msg);
    console.error(msg);
  }
}

export { Logger };
