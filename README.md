# Assignment_payamzowghi

## Implement a web application that is deployed across at least two availability zones within a single region in AWS with Terraform and bash scripting

In this activity,I learned to how to deploy WordPress service on two AWS instances as a cluster of webservers with loadbalancer(High Availability and Fault Tolerance). I specified the HTTP and HTTPS listeners send request to the instnace on port 80

Loadbalancer with an HTTPS listener(ssl_certification):

1-If we specify that the HTTPS listener sends requests to the instances on port 80, the loadbalancer terminates the requests and communication from the load balancer to the instances is not encrypted.(In my project, I use this option)

2-If the HTTPS listener sends requests to the instances on port 443, communication from the loadbalancer to the instances is encrypted.(Back_end authentication)

-Back_end authentication:What back-end authentication does is ensure that the public-key the back_end server reports (when ELB is talking to the server over HTTPS/SSL) matches a public key we provide. This would prevent somebody from attaching a malicious server to your ELB, or mitigate somebody hijacking the traffic between ELB and the servers.But in performance,we have increase in response time when communicating through ELB.



I orchestrated my AWS Infrastructure with Terraform, and create shell script as User Data to deploy WordPress service(LAMP) on AWS instances(Ubuntu 16.04). I made this environment through 4 steps:

1-step1(Create Network and Security Infrastructure)

2-step2(Create Cluster, Loadbalancer, and SSL_certification)

3-step3(Create Database and Monitoring Database)

4-step4(Create Wordpress shell script)

## Some hints before apply the environment:

1-Please read all README.md files in each step.

2-All files should be in one directory exception for bash file(wordpess_ubuntu.sh)

3-Bash file should be in a folder which is called "files". The folder must be created in the same directory that the other files in there.

4-SSL_certification should be generated as I explained in "step2/README.md"

5-Terraform.tfvars must be created in the directory with the content as variable:
````  
access_key="aws_access_key"
secret_key="aws_secret_key"
region = "us-west-2"
````
6-Run "aws configure" in command line and enter information(credential keys and region)

7-Before "apply" or "plan" run this command:
````
export TF_VAR_db_password="(YOUR_DB_PASSWORD)"
````
8-You can learn about Terraform in the site:
````
https://www.terraform.io/
````

8-After generate "keypair" and download public.key, save it on "~/.ssh" folder as ssh key.(use for ssh connection)

9-After you apply your infrastructure, Terraform generate a state file of your infrastructure, please keep it on a secure place(like S3, you can encrypt and revision your file in S3)  

## My challenges 

1-How to prevent to failure of a single location?add my subnets to different AZs

2-How to isolate my Database from outside?add my data base instance to private subnet.

3-How to connect webserver port 80 to loadbalancer securely?I use security group of loadbalancer as source

4-How to use outputs of infrastructure as variables of my wordpress bash script?I use data"template_file" option in terraform.

5-How to use metadata of instance as variables of my wordpress bash script?I use metadata instance (http://169.254.169.254/latest/meta-data/) in AWS.

6-Why my instances are healthy in ASG but they are out of service in load balancer?healthy check can't ping instances,I changed protocol to TCP:80,and it works.

7-I had some challenges to create wordpress bash script and how to deploy it in AWS instances.(explanations in step4/README.md)

## Troubleshooting

1-Check "terraform.tfstate",make sure everything is OK according our expectation about infrastructure.

2-Connect to our webserver with ssh connection,make sure everything is OK according our wordpress bash script.

3-Browse webserver's Public DNS address with http protocol,make sure we can see the wordpress page.if not,we have to check webserver's group policy.( you can check your traffic network by Protocol analyzer(tcpdump)) 

4-Check the database(in webservers)

-login to database:
````
sudo mysql --host="Endpoint of RDS" --port=3306 --user=username --password=database_password
````
-check database:
````
mysql> show databases;
````
-check user in database:
````
mysql> select user from mysql.user;
````
-which database you want to use:
````
mysql> use wordpress;
````
-list the tables in the current database:
````
mysql> show tables;
````
-It should be this table:
````
+-----------------------+
| Tables_in_wordpress   |
+-----------------------+
| wp_commentmeta        |
| wp_comments           |
| wp_links              |
| wp_options            |
| wp_postmeta           |
| wp_posts              |
| wp_term_relationships |
| wp_term_taxonomy      |
| wp_termmeta           |
| wp_terms              |
| wp_usermeta           |
| wp_users              |
+-----------------------+
````
5-Browse loadbalancer's DNS name with http protocol,if it works, we can check it out  https protocol. In this step,if we have issues,we have to check loadbalancer's listeners and loudbalancer's security group.make sure listener accepts HTTPS requests on port 443 and sends them to the instances using HTTP on port 80.

6-If we access to wordpress page by the webserver's public DNS address(http protocol), and webserver is healthy in ASG,but webservers are out of service in load balancer, check healthy check of loadbalancer.

7-After browse  loadbalancer's DNS name by https protocol,the wordpress comes up without pictures or pluging, because we use a self-signed server certificate.(we have to disable protection option in browser)

## My questions

1-How can I redirect HTTP traffic on my servers to HTTPS on my load balancer?

-The Amazon Elastic Load Balancer (ELB) supports a HTTP header called X-FORWARDED-PROTO. All the HTTPS requests going through the ELB will have the value of X-FORWARDED-PROTO equal to “HTTPS”. For the HTTP requests, you can force HTTPS by adding following simple rewrite rule.(AWS resolution) 
-add these lines to webserver.com.conf or .htaccess  file
````
RewriteEngine On
RewriteCond %{HTTP:X-Forwarded-Proto} !https
RewriteRule ^.*$ https://%{SERVER_NAME}%{REQUEST_URI}
````
but it doesn't work.

2-when updating user-data in terraform, we have to destroy instances and create again, how do we prevent this problem?

-It seems that the issue  relevant to AWS infrastructure.User data is executed only at launch. If you stop an instance, modify the user data, and start the instance, the new user data is not executed automatically.but it wouldn't be acceptable. Because we don't like to destroy our infrastructure.
