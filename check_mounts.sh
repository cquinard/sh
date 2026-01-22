#!/bin/bash

sendTeamsMessage()
{
  if [ "$1" ]; then
    curl --silent -kL --header "Content-Type: application/json" --data-binary "{\"type\":\"message\",\"attachments\":[{\"contentType\":\"application/vnd.microsoft.card.adaptive\",\"contentUrl\":null,\"content\":{\"$schema\":\"http://adaptivecards.io/schemas/adaptive-card.json\",\"type\":\"AdaptiveCard\",\"version\":\"1.2\",\"body\":[{\"type\": \"TextBlock\",\"text\": \"$1\"}]}}]}" "https://defaultf1e3115057dd4b7892083c24b9366a.23.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/7623cb519ab3422891cc90459a5c09fb/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=Ue_F5EakQo39ewMfEcQQcZCSfIM6WtiUZyuEI4BZIUE" -o /tmp/check_mounts_messages.log --trace-ascii /tmp/check_mounts_messages.trc
  fi
}

echo "$(date)" > /tmp/remount.log
grep cifs /etc/fstab |grep -v '#.*' |awk -F '/mnt' '{print "/mnt"$2}' | awk -F 'cifs' '{print $1}' |tr -d ' ' |tr -d '\t' |sort|uniq > /tmp/definition.txt
mount|grep cifs|awk -F ' on ' '{print $2}' |awk -F 'type' '{print $1}' |tr -d '\t' |tr -d ' ' |sort |uniq > /tmp/current.txt
diff /tmp/definition.txt /tmp/current.txt > /tmp/result.diff
grep '<' /tmp/result.diff | awk -F '< ' '{print $2}' > /tmp/remount.txt

while IFS= read -r READ_LINE; do
  echo "Mount FAIL: [$READ_LINE], trying to re-mount..."
  echo "Mount FAIL: [$READ_LINE], trying to re-mount...">>/tmp/remount.log
  umount $READ_LINE &>/dev/null
  mount $READ_LINE &>>/tmp/remount.log

  grep cifs /etc/fstab |grep -v '#.*' |awk -F '/mnt' '{print "/mnt"$2}' | awk -F 'cifs' '{print $1}' |tr -d ' ' |tr -d '\t' |sort|uniq > /tmp/definition2.txt
  mount|grep cifs|awk -F ' on ' '{print $2}' |awk -F 'type' '{print $1}' |tr -d '\t' |tr -d ' ' |sort |uniq > /tmp/current2.txt
  diff /tmp/definition2.txt /tmp/current2.txt > /tmp/result2.diff
  grep '<' /tmp/result2.diff | awk -F '< ' '{print $2}' > /tmp/remount2.txt

  if [ "$(grep $READ_LINE /tmp/remount2.txt)" ]; then
    echo " ... ERROR: Unable to automatically re-mount, please check [$READ_LINE] inside /tmp/remount.log"
	  sendTeamsMessage "Unable to mount $READ_LINE on $(hostname -s)."
  fi
done < /tmp/remount.txt
