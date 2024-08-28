#!/bin/bash

# Переменная для версии fractald
FRACTALD_VERSION="fractald-0.1.8-x86_64-linux-gnu"

# Главная функция меню
function main_menu() {
    while true; do
        clear
        echo "-----------------------------------------------------------------------------"
        curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
        echo "-----------------------------------------------------------------------------"
        echo "Для выхода из скрипта нажмите Ctrl+C."
        echo "Выберите опцию:"
        echo "1) Установить ноду"
        echo "2) Посмотреть логи"
        echo "3) Создать кошелек"
        echo "4) Посмотреть приватный ключ"
        echo "5) Выйти"
        echo -n "Введите номер опции [1-5]: "
        read choice
        case $choice in
            1) install_node ;;
            2) view_logs ;;
            3) create_wallet ;;
            4) view_private_key ;;
            5) exit 0 ;;
            *) echo "Неверная опция, попробуйте снова." ;;
        esac
    done
}

# Функция установки узла
function install_node() {
    echo "Начинаю обновление системы, установку пакетов..."
    # Установка необходимых пакетов
    curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
    curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
    sudo apt install gcc chrony tar gzip -y

    echo "Обновление системы и установка пакетов завершены."

    echo "Скачиваю и распаковываю fractald..."
    cd $HOME
    wget https://github.com/fractal-bitcoin/fractald-release/releases/download/v0.1.8/$FRACTALD_VERSION.tar.gz
    tar -zxvf $FRACTALD_VERSION.tar.gz
    mv $FRACTALD_VERSION fractal-node
    rm -f $FRACTALD_VERSION.tar.gz
    cd fractal-node

    # Создание директории и копирование файла конфигурации
    mkdir data
    cp ./bitcoin.conf ./data

    # Создание службы systemd
    echo "Создаю службу systemd для ноды..."
    sudo tee /etc/systemd/system/fractald.service > /dev/null <<EOF
[Unit]
Description=Fractal Node
After=network.target

[Service]
User=root
WorkingDirectory=/root/fractal-node
ExecStart=/root/fractal-node/bin/bitcoind -datadir=/root/fractal-node/data/ -maxtipage=504576000
Restart=always
RestartSec=3
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable fractald
    sudo systemctl start fractald
    
    echo "Установка ноды завершена"
    echo "-----------------------------------------------------------------------------"
    echo "Wish lifechange case with DOUBLETOP"
    echo "-----------------------------------------------------------------------------"

    # Возврат в главное меню
    read -p "Нажмите любую кнопку для возврата в главное меню..."
}

# Функция просмотра логов
function view_logs() {
    sudo journalctl -n 100 -f -u fractald -o cat
    
    # Возврат в главное меню
    read -p "Нажмите любую кнопку для возврата в главное меню..."
}

# Функция создания кошелька
function create_wallet() {
    echo "Создание кошелька..."
    cd $HOME/fractal-node/bin && ./bitcoin-wallet -wallet=wallet -legacy create
    
    # Возврат в главное меню
    read -p "Нажмите любую кнопку для возврата в главное меню..."
}

# Функция просмотра приватного ключа
function view_private_key() {
    echo "Просмотр приватного ключа..."
    
    # Переход в директорию fractal-node
    cd $HOME/fractal-node/bin
    
    # Экспорт приватного ключа с помощью bitcoin-wallet
    ./bitcoin-wallet -wallet=/root/.bitcoin/wallets/wallet/wallet.dat -dumpfile=/root/.bitcoin/wallets/wallet/MyPK.dat dump
    
    # Чтение и отображение приватного ключа
    awk -F 'checksum,' '/checksum/ {print "Приватный ключ вашего кошелька: " $2}' /root/.bitcoin/wallets/wallet/MyPK.dat
    
    # Возврат в главное меню
    read -p "Нажмите любую кнопку для возврата в главное меню..."
}

# Удаление ноды
# sudo systemctl stop fractald
# sudo systemctl disable fractald
# sudo rm /etc/systemd/system/fractald.service
# rm -rf $HOME/fractal-node

# Запуск главного меню
main_menu
