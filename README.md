# OTUS_BASH
Homework

Установил необходимое ПО  
yum install epel-release -y && yum install ssmtp -y && yum install wget -y  

Настроил ssmtp  
#Configure ssmtp  
cat << EOF >>  /etc/ssmtp/ssmtp.conf  
#!/bin/bash  
root=NNMZB@list.ru  
mailhub=smtp.mail.ru:465  
AuthUser=Asterix_i@mail.ru  
AuthPass=JxtymLkbyysqGfhjkm7  
AuthMethod=LOGIN  
UseTLS=YES  
EOF  

echo root:NNMZB@list.ru:smtp.mail.ru:465 >> /etc/ssmtp/revaliases  

Загрузил исходный лог файл  
wget https://https://github.com/Asterixi/BASH-06.12.22/.log -O /media/a.log  

Создал скрипт, выдергивающий из лог файла необходимые данные  
cat << EOF > /media/s.sh  
#!/bin/bash  
echo "#Обрабатываемый временной промежуток" > /media/log.log  
cat /media/a.log | cut -d " " -f 4 | sort | sed -n '1 p; $ p;' | sed -e 's/^.//' >> /media/log.log  
echo " " >> /media/log.log  
echo "#Самое запрашиваемое доменное имя" >> /media/log.log  
cat /media/a.log | grep GET | grep -oE https?:\/\/[a-z]*[.][a-z]* | sort -rn |uniq -c |sort -rn | sed 's/^ *//' | sed -e '1! d' >> /media/log.log  
echo " " >> /media/log.log  
echo "#Самый запрашиваемый IP" >> /media/log.log  
cat /media/a.log | grep GET | sort | cut -d " " -f 1 | uniq -c | sort -rn | sed 's/^ *//' | sed -e '1! d' >> /media/log.log  
echo " " >> /media/log.log  
echo "#Все коды возврата" >> /media/log.log >> /media/log.log  
cat /media/a.log | grep -oE 'HTTP/1.1\" [0-9][0-9][0-9]' | cut -d " " -f 2 | sort -rn | uniq -c | sort -rn | sed 's/^ *//' >> /media/log.log  
echo " " >> /media/log.log  
echo "#Коды возврата ошибок" >> /media/log.log  
cat /media/a.log | grep -oE 'HTTP/1.1\" [0-9][0-9][0-9]' | cut -d " " -f 2 | grep -E "(4[0-9][0-9]|5[0-9][0-9])" | sort -rn | uniq -c | sort -rn | sed 's/^ *//' >> /media/log.log  
EOF  

Дал полные права на его исполнение  
chmod +x /media/s.sh  

Создал скрипт для cron. В этом моменте происходит проверка на незавершенный цикл  
cat << EOF > /media/cs.sh  
#!/bin/bash  
if [[ -e /media/lockfile ]]; then  
  exit 1  
else  
touch /media/lockfile  
/media/s.sh  
echo "Log file" | /sbin/ssmtp -v -s NNMZB@list.ru -a < /media/log.log  
rm /media/lockfile -f  
fi  
EOF  

Дал полные права на его исполнение  
chmod +x /media/cs.sh  

Добавил запись в cron  
echo '*/1 */1 * * * /media/cs.sh' >>  /var/spool/cron/root  
