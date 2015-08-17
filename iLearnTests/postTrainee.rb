require "rest-client"
require "json"
url = "http://tsa-china.takeda.com.cn/uat/api/Trainee_Api.php"

hash = { UserId: "1",
    TrainingId: "3"
}
puts hash

response = RestClient.post url, hash.to_json
puts response.headers