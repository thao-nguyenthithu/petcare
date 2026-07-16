export class ApiResponse<T> {
  success!: boolean;
  statusCode!: number;
  message!: string;
  data?: T;
  timestamp!: string;

  static ok<T>(data: T, message = 'Success'): ApiResponse<T> {
    return {
      success: true,
      statusCode: 200,
      message,
      data,
      timestamp: new Date().toISOString(),
    };
  }

  static error(statusCode: number, message: string): ApiResponse<null> {
    return {
      success: false,
      statusCode,
      message,
      timestamp: new Date().toISOString(),
    };
  }
}
