#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
网站多次访问脚本
支持自定义访问次数、间隔时间、超时设置等功能
包含完整的错误处理和日志记录
"""

import requests
import time
import logging
from datetime import datetime
from typing import Optional, Dict, Any
import argparse
import sys


class WebsiteVisitor:
    """
    网站访问器类
    提供多次访问网站的功能，包含重试机制和详细日志
    """
    
    def __init__(self, url: str, headers: Optional[Dict[str, str]] = None):
        """
        初始化网站访问器
        
        Args:
            url: 目标网站URL
            headers: 自定义请求头
        """
        self.url = url
        self.headers = headers or {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        self.session = requests.Session()
        self.session.headers.update(self.headers)
        
        # 配置日志
        self._setup_logging()
        
    def _setup_logging(self) -> None:
        """
        配置日志记录器
        """
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(f'website_visit_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger(__name__)
        
    def visit_once(self, timeout: int = 10) -> Dict[str, Any]:
        """
        单次访问网站
        
        Args:
            timeout: 请求超时时间（秒）
            
        Returns:
            包含访问结果的字典
        """
        try:
            start_time = time.time()
            response = self.session.get(self.url, timeout=timeout)
            end_time = time.time()
            
            result = {
                'success': True,
                'status_code': response.status_code,
                'response_time': round(end_time - start_time, 3),
                'content_length': len(response.content),
                'timestamp': datetime.now().isoformat(),
                'error': None
            }
            
            self.logger.info(f"访问成功 - 状态码: {response.status_code}, 响应时间: {result['response_time']}s")
            return result
            
        except requests.exceptions.Timeout:
            error_msg = f"请求超时 (>{timeout}s)"
            self.logger.error(error_msg)
            return self._create_error_result(error_msg)
            
        except requests.exceptions.ConnectionError:
            error_msg = "连接错误 - 无法连接到目标网站"
            self.logger.error(error_msg)
            return self._create_error_result(error_msg)
            
        except requests.exceptions.RequestException as e:
            error_msg = f"请求异常: {str(e)}"
            self.logger.error(error_msg)
            return self._create_error_result(error_msg)
            
        except Exception as e:
            error_msg = f"未知错误: {str(e)}"
            self.logger.error(error_msg)
            return self._create_error_result(error_msg)
    
    def _create_error_result(self, error_msg: str) -> Dict[str, Any]:
        """
        创建错误结果字典
        
        Args:
            error_msg: 错误信息
            
        Returns:
            错误结果字典
        """
        return {
            'success': False,
            'status_code': None,
            'response_time': None,
            'content_length': None,
            'timestamp': datetime.now().isoformat(),
            'error': error_msg
        }
    
    def visit_multiple(self, count: int, interval: float = 1.0, 
                      timeout: int = 10, max_retries: int = 3) -> Dict[str, Any]:
        """
        多次访问网站
        
        Args:
            count: 访问次数
            interval: 访问间隔时间（秒）
            timeout: 单次请求超时时间（秒）
            max_retries: 失败重试次数
            
        Returns:
            包含所有访问结果的统计信息
        """
        self.logger.info(f"开始访问网站: {self.url}")
        self.logger.info(f"计划访问次数: {count}, 间隔: {interval}s, 超时: {timeout}s")
        
        results = []
        success_count = 0
        total_response_time = 0
        
        for i in range(count):
            self.logger.info(f"第 {i+1}/{count} 次访问")
            
            # 尝试访问，包含重试机制
            result = None
            for retry in range(max_retries + 1):
                result = self.visit_once(timeout)
                
                if result['success']:
                    success_count += 1
                    if result['response_time']:
                        total_response_time += result['response_time']
                    break
                elif retry < max_retries:
                    self.logger.warning(f"第 {retry + 1} 次重试...")
                    time.sleep(1)  # 重试前等待1秒
            
            results.append(result)
            
            # 如果不是最后一次访问，等待间隔时间
            if i < count - 1:
                time.sleep(interval)
        
        # 计算统计信息
        avg_response_time = total_response_time / success_count if success_count > 0 else 0
        
        summary = {
            'total_visits': count,
            'successful_visits': success_count,
            'failed_visits': count - success_count,
            'success_rate': round((success_count / count) * 100, 2),
            'average_response_time': round(avg_response_time, 3),
            'results': results
        }
        
        self.logger.info(f"访问完成 - 成功: {success_count}/{count} ({summary['success_rate']}%)")
        self.logger.info(f"平均响应时间: {avg_response_time:.3f}s")
        
        return summary
    
    def close(self) -> None:
        """
        关闭会话
        """
        self.session.close()


def main():
    """
    主函数 - 命令行接口
    """
    parser = argparse.ArgumentParser(description='网站多次访问工具')
    parser.add_argument('url', help='目标网站URL')
    parser.add_argument('-c', '--count', type=int, default=5, help='访问次数 (默认: 5)')
    parser.add_argument('-i', '--interval', type=float, default=1.0, help='访问间隔时间/秒 (默认: 1.0)')
    parser.add_argument('-t', '--timeout', type=int, default=10, help='请求超时时间/秒 (默认: 10)')
    parser.add_argument('-r', '--retries', type=int, default=3, help='失败重试次数 (默认: 3)')
    
    args = parser.parse_args()
    
    # 验证URL格式
    if not args.url.startswith(('http://', 'https://')):
        args.url = 'https://' + args.url
    
    # 创建访问器并执行访问
    visitor = WebsiteVisitor(args.url)
    
    try:
        summary = visitor.visit_multiple(
            count=args.count,
            interval=args.interval,
            timeout=args.timeout,
            max_retries=args.retries
        )
        
        # 打印最终统计
        print("\n=== 访问统计 ===")
        print(f"总访问次数: {summary['total_visits']}")
        print(f"成功次数: {summary['successful_visits']}")
        print(f"失败次数: {summary['failed_visits']}")
        print(f"成功率: {summary['success_rate']}%")
        print(f"平均响应时间: {summary['average_response_time']}s")
        
    except KeyboardInterrupt:
        print("\n用户中断访问")
    except Exception as e:
        print(f"程序执行错误: {e}")
    finally:
        visitor.close()


if __name__ == '__main__':
    # 示例用法
    if len(sys.argv) == 1:
        print("示例用法:")
        print("python website_visitor.py https://www.example.com")
        print("python website_visitor.py https://www.example.com -c 10 -i 2.0 -t 15")
        print("\n参数说明:")
        print("-c, --count: 访问次数")
        print("-i, --interval: 访问间隔时间（秒）")
        print("-t, --timeout: 请求超时时间（秒）")
        print("-r, --retries: 失败重试次数")
        sys.exit(1)
    
    main()