import os
import shutil
import sys

def copy_files(source_folder, destination_folder):
    """
    复制源文件夹中的所有文件到目标文件夹
    
    Args:
        source_folder (str): 源文件夹路径
        destination_folder (str): 目标文件夹路径
    """
    if not os.path.exists(source_folder):
        print(f"错误：源文件夹 '{source_folder}' 不存在")
        return
    
    if not os.path.exists(destination_folder):
        os.makedirs(destination_folder)
        print(f"创建目标文件夹：{destination_folder}")
    
    copied_count = 0
    
    for item in os.listdir(source_folder):
        source_path = os.path.join(source_folder, item)
        destination_path = os.path.join(destination_folder, item)
        
        if os.path.isfile(source_path):
            shutil.copy2(source_path, destination_path)
            print(f"已复制：{item}")
            copied_count += 1
        elif os.path.isdir(source_path):
            if os.path.exists(destination_path):
                shutil.rmtree(destination_path)
            shutil.copytree(source_path, destination_path)
            print(f"已复制文件夹：{item}")
            copied_count += 1
    
    print(f"\n复制完成！共复制了 {copied_count} 个项目")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("使用方法: python copy_files.py <源文件夹> <目标文件夹>")
        print("示例: python copy_files.py C:/source D:/destination")
        sys.exit(1)
    
    source = sys.argv[1]
    destination = sys.argv[2]
    
    copy_files(source, destination)