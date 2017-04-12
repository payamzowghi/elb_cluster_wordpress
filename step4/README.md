# Step4:

## Create wordpress shell script by LAMP(Linux, Apache, MySQL, PHP)

-The script uses as a user data in AWS infrastructure, It'll be run after instnaces launch. 
  
- Create wordpress service with shell script.

1- metadata:
````
declare instance_address=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
````
Note:

-Instance metadata:data about the instance that we can use to configure or manage the running instance.To view all categories of instance metadata from within a running instance:
````
http://169.254.169.254/latest/meta-data/
````
-Variables inside template files are used pretty much the same way they are used in Terraform templates. You need to be careful, though: dollar sign is used in both Terraform and regular bash scripts. Sometimes, you will have to escape the dollar sign, so Terraform doesn't try to interpolate it and therefore doesn't fail. Escaping is done simply by duplicating dollar sign:
$$.
````
sudo mkdir -p /var/www/html/$${instance_address}/{public_html,logs}
````
-The other items have explanations in the script file (wordpress_ubuntu.sh).
 


