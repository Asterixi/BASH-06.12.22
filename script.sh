#Install soft
yum install epel-release -y && yum install ssmtp -y && yum install wget -y

#Configure ssmtp
cat << EOF >>  /etc/ssmtp/ssmtp.conf
#!/bin/bash
root=trashscum@list.ru
mailhub=smtp.mail.ru:465
AuthUser=trashscum@list.ru
AuthPass=xVTeBPPNpJ34f5P5hjXh
AuthMethod=LOGIN
UseTLS=YES
EOF

echo root:trashscum@list.ru:smtp.mail.ru:465 >> /etc/ssmtp/revaliases

#Download logfile
wget https://raw.githubusercontent.com/Vozmen/OTUS9_BASH/main/access-4560-644067.log -O /media/a.log

#Create script
cat << EOF > /media/s.sh
#!/bin/bash
echo "#Processed time period" > /media/log.log
cat /media/a.log | cut -d " " -f 4 | sort | sed -n '1 p; $ p;' | sed -e 's/^.//' >> /media/log.log
echo " " >> /media/log.log
echo "#Most requested domain names" >> /media/log.log
cat /media/a.log | grep GET | grep -oE https?:\/\/[a-z]*[.][a-z]* | sort -rn |uniq -c |sort -rn | sed 's/^ *//' | sed -e '1,10! d' >> /media/log.log
echo " " >> /media/log.log
echo "#Most requested IP adresses" >> /media/log.log
cat /media/a.log | grep GET | sort | cut -d " " -f 1 | uniq -c | sort -rn | sed 's/^ *//' | sed -e '1,10! d' >> /media/log.log
echo " " >> /media/log.log
echo "#All exit codes" >> /media/log.log >> /media/log.log
cat /media/a.log | grep -oE 'HTTP/1.1\" [0-9][0-9][0-9]' | cut -d " " -f 2 | sort -rn | uniq -c | sort -rn | sed 's/^ *//' >> /media/log.log
echo " " >> /media/log.log
echo "#All error exit codes" >> /media/log.log
cat /media/a.log | grep -oE 'HTTP/1.1\" [0-9][0-9][0-9]' | cut -d " " -f 2 | grep -E "(4[0-9][0-9]|5[0-9][0-9])" | sort -rn | uniq -c | sort -rn | sed 's/^ *//' >> /media/log.log
EOF

#Script rights
chmod +x /media/s.sh

#Config script for Cron
cat << EOF > /media/cs.sh
#!/bin/bash
if [[ -e /media/lockfile ]]; then
  exit 1
else
touch /media/lockfile
/media/s.sh
echo "Log file" | /sbin/ssmtp -v -s trashscum@list.ru -a < /media/log.log
rm /media/lockfile -f
fi
EOF

#Script rights
chmod +x /media/cs.sh

#Config cron
echo '* */1 * * * /media/cs.sh' >>  /var/spool/cron/root
