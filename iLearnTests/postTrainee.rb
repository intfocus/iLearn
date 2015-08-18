require "rest-client"
require "json"
#url = "http://tsa-china.takeda.com.cn/uat/api/Trainee_Api.php"
#
#hash = { UserId: "1",
#    TrainingId: "3"
#}
#puts hash
#
#response = RestClient.post url, hash.to_json
#puts response.headers
#

url = "http://tsa-china.takeda.com.cn/uat/api/RollCall_Api.php"
hash = {
    TrainingId: "1",
    UserId: "2",
    IssueDate: "2015/07/18 14:33:43",
    Status: "1",
    Reason: "等快递快递收到伐",
    CreatedUser: "1"
}
response = RestClient.post url, hash.to_json
puts response.headers