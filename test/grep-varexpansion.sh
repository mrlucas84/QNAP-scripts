#!/bin/sh
apache_conf=/etc/config/apache/apache.conf
apache_custom_conf=/share/HDA_DATA/apache/apache-custom.conf

/bin/grep "apache-custom" $apache_conf
echo "1: $?"
/bin/grep "$apache_custom_conf" $apache_conf
echo "2: $?"
/bin/grep ""$apache_custom_conf"" $apache_conf
echo "3: $?"