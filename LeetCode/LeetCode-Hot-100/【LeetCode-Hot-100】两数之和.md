# 【LeetCode-Hot-100】两数之和

## 目录

[1. 目录](#目录)

[2. [题目描述](https://leetcode.cn/problems/two-sum/description/?envType=study-plan-v2&envId=top-100-liked)](#题目描述httpsleetcodecnproblemstwo-sumdescriptionenvtypestudy-plan-v2envidtop-100-liked)

[3. 分析](#分析)

[4. 答案（附带ACM模式答案）](#答案附带acm模式答案)

- [4.1 C](#c)

- [4.2 C++](#c-1)

- [4.3 JAVA](#java)

- [4.4 Python](#python)

- [4.5 JavaScript](#javascript)



## [题目描述](https://leetcode.cn/problems/two-sum/description/?envType=study-plan-v2&envId=top-100-liked)

给定一个整数数组 `nums` 和一个整数目标值 `target`，请你在该数组中找出 **和为目标值** *`target`* 的那 **两个** 整数，并返回它们的数组下标。
你可以假设每种输入只会对应一个答案。但是，数组中同一个元素在答案里不能重复出现。
你可以按任意顺序返回答案。

**示例 1：**

```
输入：nums = [2,7,11,15], target = 9
输出：[0,1]
解释：因为 nums[0] + nums[1] == 9 ，返回 [0, 1] 。
```

**示例 2：**

```
输入：nums = [3,2,4], target = 6
输出：[1,2]
```

**示例 3：**

```
输入：nums = [3,3], target = 6
输出：[0,1]
```

**提示：**

- `2 <= nums.length <= 104`
- `-109 <= nums[i] <= 109`
- `-109 <= target <= 109`
- **只会存在一个有效答案**

**进阶：**你可以想出一个时间复杂度小于 `O(n2)` 的算法吗？

## 分析

两个`for`循环很快就能够把这题搞定，但是如果要时间复杂度小于 `O(n2)` 的话则需要进一步思考。

首先，题目已经说明了数组中的**元素是不会重复出现**的，那就是说这个题目可以考虑用**哈希表的数据结构**。

其次，使用哈希表的话就需要面对一个问题：哪一部分是`Key`，哪一部分是`Value`，**具体需要看哪一部分具有唯一性**。
想象一下，我们去判断这个题会怎么做：先计算`target-num[i]`，再看`nums`里面的其他数有没有等于`taget-num[i]`的。
我们要的答案实际上就是`i`和`target-num[i]`构成的数组，**两者均具有唯一性**，因此谁作为`Key`或者`Value`都没关系。

然后，我们应该去想查看其他数是否等于差值的操作怎么做，这里要**避开第二层循环**。
其实很简单，在`for`循环时先匹配`map`中的差值，如果没有匹配就丢到`map`里就行了（统一丢给`Key`或者`Value`），这样的话判断这一步也搞定了，如果匹配成功返回即可。

## 答案（附带ACM模式答案）

### C

```c
# include <stdio.h>
# include <stdlib.h>

int* twoSum(int* nums, int numsSize, int target, int* returnSize) {
    // 为返回的数组分配空间
    int* result = (int*)malloc(2 * sizeof(int));
    // 初始化returnSize为0
    *returnSize = 0;

    // 两层循环遍历数组查找符合条件的两个数
    for (int i = 0; i < numsSize; ++i) {
        for (int j = i + 1; j < numsSize; ++j) {
            if (nums[i] + nums[j] == target) {
                // 找到结果，设置returnSize和result数组
                result[0] = i;
                result[1] = j;
                *returnSize = 2;
                return result; // 返回结果
            }
        }
    }

    // 如果没有找到结果，释放已分配的空间，并返回NULL
    free(result);
    return NULL;
}

int main() {
    int n, target;
    printf("Enter number of elements: ");
    scanf("%d", &n);

    int* nums = (int*)malloc(n * sizeof(int));
    printf("Enter %d integers: ", n);
    for (int i = 0; i < n; i++) {
        scanf("%d", &nums[i]);
    }

    printf("Enter target sum: ");
    scanf("%d", &target);

    int returnSize;
    int* indices = twoSum(nums, n, target, &returnSize);

    if (returnSize == 2) {
        // 若找到有效的两数之和等于目标值，打印它们的索引
        printf("Indices of the two numbers are: [%d, %d]\n", indices[0], indices[1]);
    } else {
        // 若未找到，打印信息
        printf("No solution found.\n");
    }

    // 释放动态分配的内存
    free(nums);
    if (indices != NULL) {
        free(indices);
    }

    return 0;
}
```

### C++

```C++
# include <iostream>
# include <string>
# include <sstream>
# include <vector>
# include <unordered_map>

class Solution {
public:
    static std::vector<int> twoSum(const std::vector<int>& nums, int target) {
        std::unordered_map<int, int> map;
        for (int i = 0; i < nums.size(); i++) {
            int complement = target - nums[i];
            if (map.find(complement) != map.end()) {
                return {map[complement], i};
            }
            map[nums[i]] = i;
        }
        return {};
    }
};

int main() {
    std::string line;
    std::getline(std::cin, line);
    std::istringstream stream(line);
    std::vector<int> nums;
    int number;
    while (stream >> number) {
        nums.push_back(number);
    }

    int target;
    std::cin >> target;

    std::vector<int> indices = Solution::twoSum(nums, target);

    if (!indices.empty()) {
        std::cout << "Indices: " << indices[0] << ", " << indices[1] << std::endl;
    } else {
        std::cout << "No solution found!" << std::endl;
    }

    return 0;
}
```

### JAVA

```java
import java.util.*;

public class Day01 {

    public static void main(String[] args) {
        // 使用Scanner从控制台读取输入
        Scanner in = new Scanner(System.in);
        // 读取一行输入，假定是以空格分隔的数字
        String numsInput = in.nextLine();
        // 读取下一个整数作为目标值
        int target = in.nextInt();
        // 将读取的行分割成字符串数组，然后将每个元素转换成整数，并最终转换成整数数组
        int[] nums = Arrays.stream(numsInput.split(" ")).mapToInt(Integer::parseInt).toArray();
        // 调用Solution类的twoSum方法，传入数字数组和目标值
        Solution.twoSum(nums, target);
    }

    // Solution类提供静态方法twoSum来找出数组中和为特定目标值的两个数的索引
    static class Solution {
        // 该方法接受一个整数数组和一个目标整数，返回两个加和为目标值的索引数组
        public static int[] twoSum(int[] nums, int target) {
            // 创建一个HashMap，用来存储数组中每个数值和其对应的索引
            Map<Integer, Integer> map = new HashMap<>();
            // 遍历整数数组
            for (int i = 0; i < nums.length; i++) {
                // 计算目标值与当前元素的差值（补数）
                int complement = target - nums[i];
                // 检查HashMap中是否已经存在补数，如果存在则找到了一对解
                if (map.containsKey(complement)) {
                    // 如果找到了，返回这两个数的索引
                    return new int[]{map.get(complement), i};
                }
                // 如果补数不存在，则将当前数值及其索引存入HashMap
                map.put(nums[i], i);
            }
            // 如果没有找到有效的两数之和等于目标值，返回一个空数组
            return new int[]{};
        }
    }
}
```

GO

```go
import (
    "fmt"
)

func main() {
    // 使用Scanner从控制台读取输入
    var numsInput string
    fmt.Scanln(&numsInput)
    // 读取下一个整数作为目标值
    var target int
    fmt.Scanln(&target)
    // 将读取的行分割成字符串数组，然后将每个元素转换成整数，并最终转换成整数数组
    nums := strings.Split(numsInput, " ")
    var numArr []int
    for _, numStr := range nums {
        num, _ := strconv.Atoi(numStr)
        numArr = append(numArr, num)
    }
    // 调用twoSum函数，传入数字数组和目标值
    twoSum(numArr, target)
}

// twoSum函数找出数组中和为特定目标值的两个数的索引
func twoSum(nums []int, target int) []int {
    // 创建一个map，用来存储数组中每个数值和其对应的索引
    numMap := make(map[int]int)
    // 遍历整数数组
    for i, num := range nums {
        // 计算目标值与当前元素的差值（补数）
        complement := target - num
        // 检查map中是否已经存在补数，如果存在则找到了一对解
        if index, ok := numMap[complement]; ok {
            // 如果找到了，返回这两个数的索引
            return []int{index, i}
        }
        // 如果补数不存在，则将当前数值及其索引存入map
        numMap[num] = i
    }
    // 如果没有找到有效的两数之和等于目标值，返回一个空数组
    return []int{}
}
```

### Python

```python
from typing import List

class Solution:
    @staticmethod
    def two_sum(nums: List[int], target: int) -> List[int]:
        num_to_index = {}
        for i, num in enumerate(nums):
            complement = target - num
            if complement in num_to_index:
                return [num_to_index[complement], i]
            num_to_index[num] = i
        return []

def main():
    nums_input = input("Enter numbers separated by spaces: ")
    target = int(input("Enter target sum: "))
    
    nums = list(map(int, nums_input.split()))
    result = Solution.two_sum(nums, target)
    
    if result:
        print("Indices of the two numbers are:", result)
    else:
        print("No two sum solution found.")

if __name__ == '__main__':
    main()
```

### JavaScript

```javascript
const twoSum = (nums, target) => {
  const map = new Map();
  for (let i = 0; i < nums.length; i++) {
    const complement = target - nums[i];
    if (map.has(complement)) {
      return [map.get(complement), i];
    }
    map.set(nums[i], i);
  }
  return [];
};

const main = () => {
  const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
  });

  readline.question('Enter numbers separated by spaces: ', (numsInput) => {
    readline.question('Enter target sum: ', (targetInput) => {
      const nums = numsInput.split(' ').map(Number);
      const target = parseInt(targetInput);
      const indices = twoSum(nums, target);
      
      if (indices.length > 0) {
        console.log(`Indices of the two numbers are: [${indices[0]}, ${indices[1]}]`);
      } else {
        console.log('No two sum solution found.');
      }
      
      readline.close();
    });
  });
};

main();
```

