gitbucket_jenkins Cookbook
==================
Install gitbucket and jenkins to Vegrant(CentOS 6.5)  
VagrantのCentOS 6.5環境にgitbucket, jenkinsのインストールを行う。  

http://Your IP Address:8080/gitbucket/  
http://Your IP Address:8080/jenkins/  

Requirements
------------
$ vagrant box add base64 CentOS-6.5-x86_64-v20140110.box

```json
{
  "user":{
    "name":"vagrant",
    "home":"/home/vagrant"
  },
  "run_list":[
    "recipe[gitbucket::default]",
    "recipe[gitbucket::tomcat-apache]"
  ]
}
```

License and Authors
-------------------
Authors: Hiroharu Tanaka
