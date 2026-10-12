#!/usr/bin/env python3

import os

def main():
    logs_dir = 'logs'
    if not os.path.isdir(logs_dir):
        print('%s not found' % logs_dir)
    # test date, kernel tree, pass/fail
    results = []
    for filename in os.listdir(logs_dir):
        test_day_dir = os.path.join(logs_dir, filename)
        if not os.path.isdir(test_day_dir):
            continue
        for kernel_tree in os.listdir(test_day_dir):
            kernel_tree_dir = os.path.join(test_day_dir, kernel_tree)
            if not os.path.isdir(kernel_tree_dir):
                continue
            for test_date in os.listdir(kernel_tree_dir):
                test_date_dir = os.path.join(kernel_tree_dir, test_date)
                if not os.path.isdir(test_date_dir):
                    continue
                for log in os.listdir(test_date_dir):
                    if not log.startswith('remote_run_corr'):
                        continue
                    log_file = os.path.join(test_date_dir, log)
                    with open(log_file, 'r') as f:
                        lines = f.read().strip().split('\n')
                        result = 'FAIL'
                        if lines[-1] == '_remote_run_corr.sh SUCCESS':
                            result = 'PASS'
                        results.append([test_date, kernel_tree, result])
    results.sort(key=lambda x: x[0])
    for test_date, kernel_tree, result in results:
        print(result, test_date, kernel_tree)

if __name__ == '__main__':
    main()
