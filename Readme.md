1) Зайти в папку cicd та згенерувати ключ, який буде використовуватись для авторизації на github при стягуванні коду
```bash
ssh-keygen -t rsa -b 4096 -C "github_deploy_key"
```
2) Зробити копію інвентаря і заповнити його
```bash
cp cicd/example.inventory.ini cicd/inventory.ini
```
3) Зробити копію змінних середовища для продакшену
```bash
cp .env.example cicd/.env.production
```
4) Зробити копію змінних середовища для локальної розробки
```bash
cp .env.example .env
```
5) Додати в інвентар публічкий ключ від ключа, який буде використовуватись для підключення до сервера по ssh.
Також додати айпі адресу сервера, шлях до приватного ключа, який потрібен для підключення під root-ом
Наприклад jenkins, щоб автоматично стягувати код з репозиторію.
У файлі cicd/firststart.sh вказати репозиторій

6) Встановити ansible
див. https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html

7) Щоб налаштувати чистий debian сервер, потрібно зайти в папку cicd і виконати наступну команду
```bash
ansible-playbook -i inventory.ini install_packages.yml
```

8) Для будь-якої системи ci/cd достатньо підключитись до серверу по ssh, зайти в папку з проектом і запустити
```bash
bash switch_traffic.sh
```

p.s. Важливо, не видаляти міграції, та не редагувати їх, якщо вона була вже запущена

p.s.2 Важливо вказати хост у dynamic/http.routers.docker-localhost.yml, наприклад schedule.knu.ua

p.s.3 За бажанням налаштувати деплой через jenkins, достатньо підняти докер контейнер будь де, 
встановити плагін ssh-agent, в налаштуваннях credentials додати ключ, який буде використовуватись для підключення до сервера
і при створенні проекту, додати step, з виконанням команди 
```bash 
ssh -o StrictHostKeyChecking=no <cicd user>@<ip> "cd www && bash switch_traffic.sh"
```
А далі, можна додавати тригери, які будуть викликати цей проект, наприклад гітхаб буде робити запит на jenkins webhook, 
або jenkins буде час від часу дивитись чи були зміни в коди 