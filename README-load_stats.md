Page Load monitor
=================


Description
-----------
Uses curl for measure load time of given web page and report results to influxdb (influxdb installation is not included in this document)

- Author: Marek Siorvy
- Contact: (msirovy (at) gmail (dot) com)


Installation
------------
1. Create influx database and user
    ```
    CREATE DATABASE metrics
    use metrics
    CREATE USER metrics_rw WITH PASSWORD 'Password4GEOmonitorinG'
    GRANT ALL ON "metrics" TO "metrics_rw"
    ```


2. set information about your influx in file load_stats.yaml

    Example load_stats.yaml file
    ```
    ---
    - name: Deploy easy monitoring satelites
      hosts: satelites
      vars:
        influx_login: metrics_rw
        influx_password: Password4GEOmonitorinG
        influx_url: http://influx.example.com:8086/write?db=geoweb
      tasks:
      - name: Copy script
        template:
          src: load_stats.sh
          dest: /usr/local/bin/load_stats.sh
          mode: 0755
          owner: root
      - name: Set crons
        cron:
          name: "{{item}}"
          job: /usr/local/bin/load_stats.sh "{{item}}" &> /dev/null
        with_items:
        - list_of_domains
    ```


3. create inventory file (called hosts for example) and specify group satelites
    Example hosts file
    ```
    [satelites]
    server1.cz.example.com
    server1.us.example.com
    server1.asia.example.com
    server1.can.example.com
    ```


4. Run ansible
    ```
    ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i hosts load_stats.yaml --diff
    ```