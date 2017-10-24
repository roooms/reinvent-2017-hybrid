#!/bin/bash

instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
new_hostname="web-server-$${instance_id}"

# set the hostname
hostnamectl set-hostname "$${new_hostname}"

# install httpd and create a landing page
yum update -y
yum install -y httpd
service httpd start
chkconfig httpd on
cat > /var/www/html/index.html <<EOF
<html>
<head>
<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.6.0/css/bulma.min.css">
<title></title>
</head>
<body style="background-color: rgb(54, 54, 54);">
<section class="hero is-dark is-large">  
  <div class="hero-body">
    <div class="container has-text-centered">
      <p class="title">HashiCorp at AWS re:Invent 2017</p>
      <p class="subtitle">$${new_hostname}</p>
    </div>
  </div>
</section>
</body>
</html>
EOF
