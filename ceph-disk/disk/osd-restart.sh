#!/bin/bash

# Renk tanımları
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # Renk sıfırlama

# Kullanıcıdan OSD numarasını al
echo -e "OSD numarasını girin: "
read -r osd

# OSD numarası doğru bir şekilde alındığında OSD'ye bağlanma adımı
if [[ -n $osd && $osd =~ ^[0-9]+$ ]]; then
  # Ceph OSD crush tree çıktısından ilgili hostu al
  host=$(ceph osd crush tree | grep "osd\.$osd[^0-9]\|host" | grep -B 1 "osd\.$osd[^0-9]" | grep -v "osd\.$osd[^0-9]" | awk '{print $5}')

  # OSD numarasına sahip host'a SSH ile bağlan ve servis durumunu kontrol et
  if [[ -n $host ]]; then
    echo -e "OSD numarası ${GREEN}$osd${NC} olan cihazın bağlı olduğu host: ${GREEN}$host${NC}"
    ssh "$host" "systemctl restart ceph-osd@$osd"
  else
    echo -e "${RED}OSD numarası $osd için uygun bir host bulunamadı.${NC}"
  fi
else
  echo -e "${RED}Geçersiz OSD numarası girdiniz. Lütfen bir sayı girin.${NC}"
fi
