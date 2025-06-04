1、创建网络：

- `docker network create molprobity_service`

  

2、不同容器使用同一网络，用于互联：

- ```
  docker run -it --name molprobity-server --network molprobity_service -p 8920:8920 -p 8899:80 -v /mnt/data1/bioford2:/app -e HOST_MOUNT_PATH="/mnt/data1/bioford2" --gpus '"device=0,1,2"' --rm molprobity_api /bin/bash
  ```

- ```
  docker run -it --network molprobity_service -p 8913:8913 -v /mnt/data1/bioford2:/app -v /mnt/data2/data:/app/data -e HOST_MOUNT_PATH="/mnt/data1/bioford2" --gpus '"device=0,1,2"'  vit-struct_api /bin/bash
  ```

  

3、vit-struct_api容器使用molprobity-server：

```python
def pdb_evaluate(pdb_file_path: str, service_url: str = "http://molprobity-server:8920/evaluate") -> Dict:
    """
    参数:
        pdb_file_path: PDB文件路径（客户端容器内路径）
        service_url: 服务地址（默认为本地服务）
    
    返回:
        Dict: 服务端返回的JSON响应
    
    异常:
        FileNotFoundError: 文件不存在
        requests.RequestException: 网络或服务请求失败
        ValueError: JSON解析失败或服务返回无效响应
    """
    try:
        # 检查文件是否存在
        if not os.path.exists(pdb_file_path):
            raise FileNotFoundError(f"File not found in client container: {pdb_file_path}")
        
        # 发送POST请求
        response = requests.post(
            service_url,
            json={"file_path": pdb_file_path},  # 注意路径需在服务端容器内可见
        )
        response.raise_for_status()  # 检查HTTP状态码（非2xx会抛异常）
        
        # 解析JSON响应
        result = response.json()["eval_result_path"]
        return result
        
    except FileNotFoundError as e:
        raise  # 直接重新抛出已知异常（保留原始堆栈）
    except requests.Timeout:
        raise RuntimeError(f"Request to {service_url} timed out")
    except requests.RequestException as e:
        raise RuntimeError(f"Failed to call service: {str(e)}")
    except ValueError as e:
        raise ValueError(f"Invalid JSON response from service: {str(e)}")
```

