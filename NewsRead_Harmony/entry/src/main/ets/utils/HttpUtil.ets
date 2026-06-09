import http from '@ohos.net.http';

let token: string = '';

export function setToken(t: string): void {
  console.log('Token set');
  token = t;
}

export function getToken(): string {
  console.log('Token retrieved');
  return token;
}

const BASE_URL = 'http://10.0.2.2:8080/api';

export async function request<T>(url: string, method: http.RequestMethod, extraData?: string): Promise<T> {
  const httpRequest = http.createHttp();

  console.log('HTTP Request: ' + url);

  try {
    // 1. 严格使用 Record 构造请求头，避免匿名对象报错
    let headerObj: Record<string, string> = {};
    headerObj['Content-Type'] = 'application/json';

    // 添加 Token 头（非登录请求且token存在时）
    if (token && !url.includes('/login')) {
      headerObj['Authorization'] = 'Bearer ' + token;
      console.log('Added Authorization header');
    } else {
      console.log('No auth header for: ' + url);
    }

    // 2. 严格使用系统提供的 HttpRequestOptions 类型
    let options: http.HttpRequestOptions = {
      method: method,
      header: headerObj,
      extraData: extraData,
      expectDataType: http.HttpDataType.STRING // 推荐：直接要求返回字符串
    };

    // 3. 必须使用原生的 http.HttpResponse 接收结果
    const response: http.HttpResponse = await httpRequest.request(
      BASE_URL + url,
      options
    );

    console.log('HTTP Response Code:', response.responseCode);
    console.log('HTTP Response Result:', JSON.stringify(response.result));

    if (response.responseCode >= 200 && response.responseCode < 300) {
      // 4. 安全地处理返回的 result，解决类型不匹配报错
      let resString: string = '';
      if (typeof response.result === 'string') {
        resString = response.result;
      } else {
        resString = JSON.stringify(response.result);
      }

      console.log('HTTP Response:', resString);
      const resultObj = JSON.parse(resString) as Record<string, Object>;
      const code = resultObj['code'] as number;

      if (code === 200 || code === 201) {
        const data = resultObj['data'];
        if (data === undefined || data === null) {
          throw new Error('响应数据为空');
        }
        return data as T;
      }

      const message = (resultObj['message'] as string) || '请求失败';
      throw new Error(message);
    }

    // 处理错误响应
    let resString: string = '';
    if (typeof response.result === 'string') {
      resString = response.result;
    } else {
      resString = JSON.stringify(response.result);
    }

    try {
      const resultObj = JSON.parse(resString) as Record<string, Object>;
      const message = (resultObj['message'] as string) || '请求失败';
      throw new Error(message);
    } catch (e) {
      if (e instanceof Error && e.message !== '') {
        throw e;
      }
      throw new Error(`HTTP ${response.responseCode}`);
    }
  } catch (err) {
    // 5. 必须捕获异常，解决 warning: Function may throw exceptions
    let errMsg: string = '请求失败';
    if (err instanceof Error) {
      errMsg = err.message;
    } else {
      errMsg = JSON.stringify(err);
    }
    console.error('HTTP Request Error: ' + errMsg);

    throw new Error(errMsg);
  } finally {
    httpRequest.destroy();
  }
}

export async function get<T>(url: string, params: Record<string, string | number>): Promise<T> {
  let queryString = '';
  const keys = Object.keys(params);
  if (keys.length > 0) {
    const parts: string[] = [];
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i];
      const value = params[key];
      if (value !== undefined && value !== null) {
        parts.push(key + '=' + value.toString());
      }
    }
    if (parts.length > 0) {
      queryString = '?' + parts.join('&');
    }
  }
  return request<T>(url + queryString, http.RequestMethod.GET);
}

// 6. 参数 data 类型改为 Object，避免外部调用时复杂的类型强转
export async function post<T>(url: string, data: Object): Promise<T> {
  const jsonStr = JSON.stringify(data);
  return request<T>(url, http.RequestMethod.POST, jsonStr);
}

export async function put<T>(url: string, data: Object): Promise<T> {
  const jsonStr = JSON.stringify(data);
  return request<T>(url, http.RequestMethod.PUT, jsonStr);
}

export async function del<T>(url: string): Promise<T> {
  return request<T>(url, http.RequestMethod.DELETE);
}