#!/bin/sh
APACHE_CONF="/etc/config/apache/apache.conf"
is_conf_broken()
{
	conf_size_min=4096
	conf_size=`/usr/bin/du -b "${APACHE_CONF}" | /bin/awk '{print $1}'`
	[ ! -z $conf_size -a $conf_size -le $conf_size_min ] && return 1
	if [ -x /usr/local/apache/bin/apache ]; then
		/usr/local/apache/bin/apache -t -f "${APACHE_CONF}" 1>/dev/null 2>/dev/null
		[ $? = 0 ] || return 1
	fi
	miss=0
	/bin/grep "^ServerRoot" "${APACHE_CONF}" >/dev/null
	[ $? = 0 ] || miss=$(($miss+1))
	/bin/grep "^Listen" "${APACHE_CONF}" >/dev/null
	[ $? = 0 ] || miss=$(($miss+1))
	/bin/grep "^DocumentRoot" "${APACHE_CONF}" >/dev/null
	[ $? = 0 ] || miss=$(($miss+1))
	/bin/grep "/home/httpd/v3_menu" "${APACHE_CONF}" >/dev/null
	[ $? = 0 ] || miss=$(($miss+1))
	[ $miss -eq 0  ] || return 1
	return 0
}
is_conf_broken
if [ $? = 0 ]
	then
		echo "Config ok"
	else
		echo "Config broken"
fi