import sys
import filecmp
import subprocess
import sys
import os


# 主函数
def main():
    #print(sys.argv[0] + ' ' + sys.argv[1] + ' ' + sys.argv[2])

    # 1.将bin文件转成mem文件
    cmd = r'python ../tools/BinToMem_CLI.py' + ' ' + sys.argv[1] + ' ' + sys.argv[2]
    f = os.popen(cmd)
    f.close()

    # 2.编译rtl文件
    cmd = r'python compile_rtl.py' + r' ..'
    f = os.popen(cmd)
    f.close()

    # 3.运行
    vvp_cmd = [r'vvp']
    vvp_cmd.append(r'out.vvp')
    process = subprocess.Popen(vvp_cmd)
    try:
        process.wait(timeout=20)
    except subprocess.TimeoutExpired:
        print('!!!Fail, vvp exec timeout!!!')


if __name__ == '__main__':
    sys.exit(main())
