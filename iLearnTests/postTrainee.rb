require "rest-client"
require "json"


def postForm(url, param, info)
    begin
        response = RestClient.post url, param.to_json
        
        if response.code == 200
            puts "#{info} 成功."
        else
            puts "#{info} 失败."
            puts response.headers
        end
    rescue => e
      puts "#{info} 失败 for #{e.message}"
    end
end

# 学员报名信息维护
url = "http://tsa-china.takeda.com.cn/uat/api/Trainee_Api.php"

hash = {
    UserId: "1",
    TrainingId: "3"
}
postForm(url, hash, "学员报名信息维护")


# 上传点名信息维护
url = "http://tsa-china.takeda.com.cn/uat/api/RollCall_Api.php"
hash = {
    TrainingId: "1",
    UserId: "2",
    IssueDate: "2015/07/18 14:33:43",
    Status: "1",
    Reason: "等快递快递收到伐",
    CreatedUser: "1"
}
postForm(url, hash, "上传点名信息维护")


# 创建签到
url = "http://tsa-china.takeda.com.cn/uat/api/CheckIn_Api.php"
hash = {
    UserId: "8",#创建用户
    CheckInName: "ccssdd",#签到名称
    CheckInId: "5",#签到ID，修改和删除时生效
    Status: "-1",#状态（0：新增，1：修改，-1：删除）
    TrainingId: "1"#课程编号
}
postForm(url, hash, "创建签到")
