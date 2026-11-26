# /Satoshi:25.0.0/ and /Satoshi:25.1.0/ clients disrespecting fRelay

b10c | 2026-10-19 20:54:13 UTC | #1

These IP addresses of v25.0 / v25.1 clients disrespecting fRelay were shared with me. They belong to different cloud providers (seeing Hetzner, Google, AWS, ...):

```
# Google
104.199.210.140 /Satoshi:25.1.0/
104.199.67.60 /Satoshi:25.1.0/
# DigitalOcean
104.248.105.14 /Satoshi:25.1.0/
104.248.105.58 /Satoshi:25.1.0/
# Hetzner
116.202.176.80 /Satoshi:25.1.0/
116.202.176.89 /Satoshi:25.1.0/
116.202.180.130 /Satoshi:25.1.0/
116.202.182.4 /Satoshi:25.1.0/
116.202.184.128 /Satoshi:25.1.0/
116.202.187.210 /Satoshi:25.1.0/
116.202.188.10 /Satoshi:25.1.0/
116.202.190.162 /Satoshi:25.1.0/
116.202.5.166 /Satoshi:25.1.0/
116.203.11.226 /Satoshi:25.1.0/
116.203.165.228 /Satoshi:25.1.0/
116.203.4.239 /Satoshi:25.1.0/
# AWS
13.124.60.190 /Satoshi:25.0.0/
13.202.3.170 /Satoshi:25.0.0/
13.244.190.138 /Satoshi:25.0.0/
13.245.58.123 /Satoshi:25.0.0/
13.246.87.161 /Satoshi:25.0.0/
13.247.1.70 /Satoshi:25.0.0/
13.36.183.251 /Satoshi:25.0.0/
13.37.8.33 /Satoshi:25.0.0/
13.39.131.42 /Satoshi:25.0.0/
13.41.145.246 /Satoshi:25.0.0/
13.42.157.173 /Satoshi:25.0.0/
13.43.158.168 /Satoshi:25.0.0/
13.48.158.201 /Satoshi:25.0.0/
13.50.230.87 /Satoshi:25.0.0/
13.50.27.242 /Satoshi:25.0.0/
13.53.149.85 /Satoshi:25.0.0/
13.53.202.93 /Satoshi:25.0.0/
13.53.55.1 /Satoshi:25.0.0/
13.53.88.24 /Satoshi:25.0.0/
# ...
139.59.29.131 /Satoshi:25.1.0/
139.59.29.141 /Satoshi:25.1.0/
143.110.209.237 /Satoshi:25.1.0/
143.198.210.127 /Satoshi:25.1.0/
146.148.120.238 /Satoshi:25.1.0/
146.190.179.145 /Satoshi:27.1.0/
146.190.179.176 /Satoshi:27.1.0/
146.190.9.1 /Satoshi:25.1.0/
15.156.130.109 /Satoshi:25.0.0/
15.161.168.23 /Satoshi:25.0.0/
15.161.17.137 /Satoshi:25.0.0/
15.184.115.111 /Satoshi:25.0.0/
15.185.133.203 /Satoshi:25.0.0/
15.185.160.165 /Satoshi:25.0.0/
15.206.154.8 /Satoshi:25.0.0/
15.236.87.36 /Satoshi:25.0.0/
15.236.9.153 /Satoshi:25.0.0/
152.42.148.185 /Satoshi:25.1.0/
152.42.148.186 /Satoshi:25.1.0/
159.203.28.156 /Satoshi:25.1.0/
159.223.52.111 /Satoshi:25.1.0/
16.162.75.123 /Satoshi:25.0.0/
16.163.61.38 /Satoshi:25.0.0/
16.16.60.40 /Satoshi:25.0.0/
16.170.6.3 /Satoshi:25.0.0/
16.171.204.210 /Satoshi:25.0.0/
16.171.77.208 /Satoshi:25.0.0/
16.24.85.251 /Satoshi:25.0.0/
164.90.253.129 /Satoshi:25.1.0/
167.172.59.132 /Satoshi:25.1.0/
167.172.6.199 /Satoshi:25.1.0/
167.172.6.57 /Satoshi:25.1.0/
167.71.140.88 /Satoshi:25.1.0/
175.41.175.168 /Satoshi:25.0.0/
18.102.112.251 /Satoshi:25.0.0/
18.102.1.124 /Satoshi:25.0.0/
18.102.127.244 /Satoshi:25.0.0/
18.102.131.67 /Satoshi:25.0.0/
18.102.136.143 /Satoshi:25.0.0/
18.102.138.215 /Satoshi:25.0.0/
18.102.144.67 /Satoshi:25.0.0/
18.102.157.154 /Satoshi:25.0.0/
18.102.183.177 /Satoshi:25.0.0/
18.102.215.101 /Satoshi:25.0.0/
18.102.250.210 /Satoshi:25.0.0/
18.102.255.233 /Satoshi:25.0.0/
18.102.27.180 /Satoshi:25.0.0/
18.102.40.24 /Satoshi:25.0.0/
18.130.93.24 /Satoshi:25.0.0/
18.133.128.214 /Satoshi:25.0.0/
18.135.184.243 /Satoshi:25.0.0/
18.153.213.44 /Satoshi:25.0.0/
18.170.144.243 /Satoshi:25.0.0/
18.170.246.153 /Satoshi:25.0.0/
18.171.80.241 /Satoshi:25.0.0/
18.192.17.10 /Satoshi:25.0.0/
18.194.43.121 /Satoshi:25.0.0/
192.81.217.47 /Satoshi:25.1.0/
195.201.255.223 /Satoshi:25.1.0/
195.201.46.163 /Satoshi:25.1.0/
204.236.166.77 /Satoshi:25.0.0/
206.189.180.38 /Satoshi:25.1.0/
207.154.198.196 /Satoshi:27.1.0/
207.154.201.62 /Satoshi:27.1.0/
209.38.162.70 /Satoshi:25.1.0/
209.38.162.73 /Satoshi:25.1.0/
209.38.173.180 /Satoshi:25.1.0/
2400:6180:0:d2::78b7 /Satoshi:25.1.0/
24.144.65.15 /Satoshi:25.1.0/
24.199.120.126 /Satoshi:25.1.0/
24.199.121.156 /Satoshi:25.1.0/
2604:a880:400:d1::6143 /Satoshi:25.1.0/
2604:a880:4:1d0::1fd3 /Satoshi:25.1.0/
2604:a880:cad:d0::75b2 /Satoshi:25.1.0/
2a01:4f8:1c0c:8174: /Satoshi:25.1.0/
2a01:4f8:1c0c:8297: /Satoshi:25.1.0/
2a01:4f8:1c0c:8324: /Satoshi:25.1.0/
2a01:4f8:1c0c:b00d: /Satoshi:25.1.0/
2a01:4f8:1c17:80b5: /Satoshi:25.1.0/
2a01:4f8:1c17:a03c: /Satoshi:25.1.0/
2a01:4f8:1c17:a0c4: /Satoshi:25.1.0/
2a01:4f8:1c17:b0a0: /Satoshi:25.1.0/
2a01:4f8:1c17:b3da: /Satoshi:25.1.0/
2a01:4f8:1c17:b5d9: /Satoshi:25.1.0/
2a01:4f8:c01f:132: /Satoshi:25.1.0/
2a01:4f9:c01f:22: /Satoshi:25.1.0/
2a01:4f9:c01f:2f: /Satoshi:25.1.0/
2a01:4f9:c01f:805e: /Satoshi:25.1.0/
2a01:4f9:c01f:85bd: /Satoshi:25.1.0/
2a01:4f9:c01f:a4b0: /Satoshi:25.1.0/
2a01:4f9:c01f:a7: /Satoshi:25.1.0/
2a01:4f9:c01f:bd: /Satoshi:25.1.0/
2a01:4f9:c01f:be: /Satoshi:25.1.0/
2a01:4f9:c01f:e013: /Satoshi:25.1.0/
2a01:4f9:c01f:e0a2: /Satoshi:25.1.0/
2a01:4f9:c01f:e0a7: /Satoshi:25.1.0/
2a03:b0c0:2:f0::1bed /Satoshi:25.1.0/
2a03:b0c0:3:f0::2cc5 /Satoshi:27.1.0/
2a05:d012:42a:5700:a10:d6d0:be59 /Satoshi:25.0.0/
2a05:d014:a55:4000:7b8f:5846:8bea /Satoshi:25.0.0/
2a05:d014:a55:4000:c41f:de69:1237 /Satoshi:25.0.0/
2a05:d016:98f:5200:2110:bfc6:f5c /Satoshi:25.0.0/
2a05:d016:98f:5200:ec05:fc0f:39ce /Satoshi:25.0.0/
2a05:d018:a75:6c00:8e8c:4739:ef0d /Satoshi:25.0.0/
2a05:d01a:b7b:3c00:18ad:84b6:cb0d /Satoshi:25.0.0/
2a05:d01a:b7b:3c00:6c53:ed34:3d90 /Satoshi:25.0.0/
2a05:d01c:672:9200:57f8:cdb6:6d21 /Satoshi:25.0.0/
2a05:d01c:672:9200:603c:6c3e:4996 /Satoshi:25.0.0/
3.11.63.47 /Satoshi:25.0.0/
3.126.102.1 /Satoshi:25.0.0/
3.126.112.133 /Satoshi:25.0.0/
3.136.178.225 /Satoshi:25.0.0/
3.138.38.13 /Satoshi:25.0.0/
3.138.62.60 /Satoshi:25.0.0/
3.146.133.93 /Satoshi:25.0.0/
3.24.133.127 /Satoshi:25.0.0/
3.39.147.164 /Satoshi:25.0.0/
34.101.103.184 /Satoshi:25.1.0/
34.101.105.12 /Satoshi:25.1.0/
34.101.132.198 /Satoshi:25.1.0/
34.101.179.157 /Satoshi:25.1.0/
34.101.186.228 /Satoshi:25.1.0/
34.101.205.132 /Satoshi:25.1.0/
34.101.229.34 /Satoshi:25.1.0/
34.101.247.157 /Satoshi:25.1.0/
34.101.77.203 /Satoshi:25.1.0/
34.102.53.81 /Satoshi:25.1.0/
34.102.75.53 /Satoshi:25.1.0/
34.102.97.163 /Satoshi:25.1.0/
34.106.105.122 /Satoshi:25.1.0/
34.106.106.52 /Satoshi:25.1.0/
34.106.114.222 /Satoshi:25.1.0/
34.106.169.146 /Satoshi:25.1.0/
34.106.233.250 /Satoshi:25.1.0/
34.106.237.35 /Satoshi:25.1.0/
34.106.48.163 /Satoshi:25.1.0/
34.106.51.173 /Satoshi:25.1.0/
34.106.53.91 /Satoshi:25.1.0/
34.107.114.79 /Satoshi:25.1.0/
34.107.51.77 /Satoshi:25.1.0/
34.116.72.119 /Satoshi:25.1.0/
34.116.83.230 /Satoshi:25.1.0/
34.121.56.218 /Satoshi:25.1.0/
34.123.213.165 /Satoshi:25.1.0/
34.125.112.156 /Satoshi:25.1.0/
34.125.126.33 /Satoshi:25.1.0/
34.125.177.239 /Satoshi:25.1.0/
34.125.180.222 /Satoshi:25.1.0/
34.125.46.3 /Satoshi:25.1.0/
34.125.47.186 /Satoshi:25.1.0/
34.125.67.59 /Satoshi:25.1.0/
34.125.72.57 /Satoshi:25.1.0/
34.125.77.92 /Satoshi:25.1.0/
34.125.88.170 /Satoshi:25.1.0/
34.126.107.179 /Satoshi:25.1.0/
34.126.115.35 /Satoshi:25.1.0/
34.126.120.20 /Satoshi:25.1.0/
34.126.67.135 /Satoshi:25.1.0/
34.139.233.110 /Satoshi:25.1.0/
34.140.225.85 /Satoshi:25.1.0/
34.141.15.137 /Satoshi:25.1.0/
34.142.96.193 /Satoshi:25.1.0/
34.146.117.255 /Satoshi:25.1.0/
34.147.174.98 /Satoshi:25.1.0/
34.147.203.110 /Satoshi:25.1.0/
34.147.222.234 /Satoshi:25.1.0/
34.148.85.193 /Satoshi:25.1.0/
34.150.1.226 /Satoshi:25.1.0/
34.151.90.204 /Satoshi:25.1.0/
34.159.213.150 /Satoshi:25.1.0/
34.159.80.237 /Satoshi:25.1.0/
34.168.46.125 /Satoshi:25.1.0/
34.169.6.187 /Satoshi:25.1.0/
34.197.216.229 /Satoshi:25.0.0/
34.205.241.150 /Satoshi:25.0.0/
34.21.17.250 /Satoshi:25.1.0/
34.225.190.46 /Satoshi:25.0.0/
34.38.151.19 /Satoshi:25.1.0/
34.40.131.0 /Satoshi:25.1.0/
34.40.138.251 /Satoshi:25.1.0/
34.46.100.151 /Satoshi:25.1.0/
34.46.173.141 /Satoshi:25.1.0/
34.48.121.218 /Satoshi:25.1.0/
34.48.140.203 /Satoshi:25.1.0/
34.48.164.125 /Satoshi:25.1.0/
34.48.38.29 /Satoshi:25.1.0/
34.57.143.157 /Satoshi:25.1.0/
34.65.131.136 /Satoshi:25.1.0/
34.65.153.231 /Satoshi:25.1.0/
34.65.190.240 /Satoshi:25.1.0/
34.65.20.183 /Satoshi:25.1.0/
34.65.213.109 /Satoshi:25.1.0/
34.65.249.230 /Satoshi:25.1.0/
34.66.68.153 /Satoshi:25.1.0/
34.69.227.1 /Satoshi:25.1.0/
34.72.51.95 /Satoshi:25.1.0/
34.74.178.245 /Satoshi:25.1.0/
34.75.109.94 /Satoshi:25.1.0/
34.75.128.167 /Satoshi:25.1.0/
34.76.60.147 /Satoshi:25.1.0/
34.79.69.192 /Satoshi:25.1.0/
34.80.143.38 /Satoshi:25.1.0/
34.81.223.172 /Satoshi:25.1.0/
34.81.228.112 /Satoshi:25.1.0/
34.81.91.196 /Satoshi:25.1.0/
34.82.210.229 /Satoshi:25.1.0/
34.82.26.8 /Satoshi:25.1.0/
34.82.27.114 /Satoshi:25.1.0/
34.83.121.133 /Satoshi:25.1.0/
34.83.195.103 /Satoshi:25.1.0/
34.83.21.121 /Satoshi:25.1.0/
34.84.48.217 /Satoshi:25.1.0/
34.84.69.151 /Satoshi:25.1.0/
34.86.4.204 /Satoshi:25.1.0/
34.87.112.13 /Satoshi:25.1.0/
34.87.168.12 /Satoshi:25.1.0/
34.87.188.136 /Satoshi:25.1.0/
34.87.216.102 /Satoshi:25.1.0/
34.87.61.90 /Satoshi:25.1.0/
34.89.207.91 /Satoshi:25.1.0/
34.89.78.16 /Satoshi:25.1.0/
34.89.8.200 /Satoshi:25.1.0/
34.90.103.131 /Satoshi:25.1.0/
34.90.104.47 /Satoshi:25.1.0/
34.90.157.209 /Satoshi:25.1.0/
34.90.70.223 /Satoshi:25.1.0/
34.91.140.191 /Satoshi:25.1.0/
34.91.188.86 /Satoshi:25.1.0/
34.91.195.229 /Satoshi:25.1.0/
34.91.41.138 /Satoshi:25.1.0/
34.91.86.7 /Satoshi:25.1.0/
34.92.126.92 /Satoshi:25.1.0/
34.92.233.106 /Satoshi:25.1.0/
34.92.235.236 /Satoshi:25.1.0/
34.92.27.145 /Satoshi:25.1.0/
34.92.75.44 /Satoshi:25.1.0/
34.93.116.89 /Satoshi:25.1.0/
34.93.152.123 /Satoshi:25.1.0/
34.93.206.77 /Satoshi:25.1.0/
34.93.222.205 /Satoshi:25.1.0/
34.94.135.10 /Satoshi:25.1.0/
34.94.55.181 /Satoshi:25.1.0/
34.95.0.69 /Satoshi:25.1.0/
34.95.164.161 /Satoshi:25.1.0/
34.95.17.184 /Satoshi:25.1.0/
34.95.29.216 /Satoshi:25.1.0/
34.95.38.162 /Satoshi:25.1.0/
34.95.39.53 /Satoshi:25.1.0/
34.96.170.247 /Satoshi:25.1.0/
34.97.110.74 /Satoshi:25.1.0/
34.97.134.215 /Satoshi:25.1.0/
34.97.142.205 /Satoshi:25.1.0/
34.97.148.44 /Satoshi:25.1.0/
34.97.22.229 /Satoshi:25.1.0/
34.97.29.29 /Satoshi:25.1.0/
34.97.40.102 /Satoshi:25.1.0/
34.97.78.39 /Satoshi:25.1.0/
34.97.86.22 /Satoshi:25.1.0/
35.157.36.205 /Satoshi:25.0.0/
35.178.110.135 /Satoshi:25.0.0/
35.178.97.13 /Satoshi:25.0.0/
35.179.219.120 /Satoshi:25.0.0/
35.179.229.231 /Satoshi:25.0.0/
35.180.215.61 /Satoshi:25.0.0/
35.181.102.181 /Satoshi:25.0.0/
35.181.115.229 /Satoshi:25.0.0/
35.182.131.76 /Satoshi:25.0.0/
35.185.180.184 /Satoshi:25.1.0/
35.186.186.240 /Satoshi:25.1.0/
35.187.156.83 /Satoshi:25.1.0/
35.187.203.217 /Satoshi:25.1.0/
35.189.209.146 /Satoshi:25.1.0/
35.189.21.27 /Satoshi:25.1.0/
35.189.27.146 /Satoshi:25.1.0/
35.194.121.184 /Satoshi:25.1.0/
35.195.170.141 /Satoshi:25.1.0/
35.195.196.38 /Satoshi:25.1.0/
35.196.178.88 /Satoshi:25.1.0/
35.197.240.139 /Satoshi:25.1.0/
35.199.107.158 /Satoshi:25.1.0/
35.199.159.226 /Satoshi:25.1.0/
35.199.31.130 /Satoshi:25.1.0/
35.199.76.65 /Satoshi:25.1.0/
35.199.88.255 /Satoshi:25.1.0/
35.200.167.38 /Satoshi:25.1.0/
35.200.203.112 /Satoshi:25.1.0/
35.200.208.95 /Satoshi:25.1.0/
35.200.231.26 /Satoshi:25.1.0/
35.200.237.93 /Satoshi:25.1.0/
35.200.48.92 /Satoshi:25.1.0/
35.200.50.144 /Satoshi:25.1.0/
35.200.52.184 /Satoshi:25.1.0/
35.201.210.216 /Satoshi:25.1.0/
35.203.10.112 /Satoshi:25.1.0/
35.203.15.57 /Satoshi:25.1.0/
35.203.41.106 /Satoshi:25.1.0/
35.203.49.27 /Satoshi:25.1.0/
35.203.55.159 /Satoshi:25.1.0/
35.204.253.254 /Satoshi:25.1.0/
35.220.203.91 /Satoshi:25.1.0/
35.220.240.121 /Satoshi:25.1.0/
35.221.110.45 /Satoshi:25.1.0/
35.221.96.183 /Satoshi:25.1.0/
35.226.53.239 /Satoshi:25.1.0/
35.228.132.48 /Satoshi:25.1.0/
35.228.210.96 /Satoshi:25.1.0/
35.228.225.73 /Satoshi:25.1.0/
35.228.238.236 /Satoshi:25.1.0/
35.228.239.128 /Satoshi:25.1.0/
35.228.251.146 /Satoshi:25.1.0/
35.228.71.136 /Satoshi:25.1.0/
35.228.95.22 /Satoshi:25.1.0/
35.229.123.111 /Satoshi:25.1.0/
35.231.65.108 /Satoshi:25.1.0/
35.232.112.59 /Satoshi:25.1.0/
35.234.120.171 /Satoshi:25.1.0/
35.234.7.49 /Satoshi:25.1.0/
35.235.115.218 /Satoshi:25.1.0/
35.236.127.203 /Satoshi:25.1.0/
35.236.13.203 /Satoshi:25.1.0/
35.236.139.246 /Satoshi:25.1.0/
35.236.203.5 /Satoshi:25.1.0/
35.236.40.112 /Satoshi:25.1.0/
35.236.99.109 /Satoshi:25.1.0/
35.237.109.49 /Satoshi:25.1.0/
35.237.144.170 /Satoshi:25.1.0/
35.240.108.64 /Satoshi:25.1.0/
35.240.252.177 /Satoshi:25.1.0/
35.242.187.91 /Satoshi:25.1.0/
35.242.225.82 /Satoshi:25.1.0/
35.244.117.249 /Satoshi:25.1.0/
35.244.9.182 /Satoshi:25.1.0/
35.245.48.171 /Satoshi:25.1.0/
35.246.245.198 /Satoshi:25.1.0/
35.246.247.12 /Satoshi:25.1.0/
35.246.65.132 /Satoshi:25.1.0/
35.247.228.106 /Satoshi:25.1.0/
35.247.241.173 /Satoshi:25.1.0/
35.247.39.60 /Satoshi:25.1.0/
3.64.40.45 /Satoshi:25.0.0/
3.71.155.171 /Satoshi:25.0.0/
3.79.173.211 /Satoshi:25.0.0/
3.79.174.240 /Satoshi:25.0.0/
3.98.12.66 /Satoshi:25.0.0/
3.99.90.171 /Satoshi:25.0.0/
43.199.102.207 /Satoshi:25.0.0/
43.199.79.18 /Satoshi:25.0.0/
43.202.136.251 /Satoshi:25.0.0/
43.204.163.75 /Satoshi:25.0.0/
44.238.17.100 /Satoshi:25.0.0/
46.51.133.244 /Satoshi:25.0.0/
49.12.112.75 /Satoshi:25.1.0/
49.12.118.243 /Satoshi:25.1.0/
51.20.197.29 /Satoshi:25.0.0/
51.20.229.184 /Satoshi:25.0.0/
51.21.122.218 /Satoshi:25.0.0/
51.21.26.87 /Satoshi:25.0.0/
51.21.93.155 /Satoshi:25.0.0/
52.12.224.35 /Satoshi:25.0.0/
52.195.112.56 /Satoshi:25.0.0/
52.47.46.214 /Satoshi:25.0.0/
52.51.25.159 /Satoshi:25.0.0/
52.52.8.0 /Satoshi:25.0.0/
52.56.50.54 /Satoshi:25.0.0/
52.56.64.87 /Satoshi:25.0.0/
52.57.165.2 /Satoshi:25.0.0/
52.65.243.205 /Satoshi:25.0.0/
52.65.41.72 /Satoshi:25.0.0/
52.67.245.170 /Satoshi:25.0.0/
52.78.231.92 /Satoshi:25.0.0/
52.8.217.50 /Satoshi:25.0.0/
54.154.212.14 /Satoshi:25.0.0/
54.170.73.194 /Satoshi:25.0.0/
54.176.174.116 /Satoshi:25.0.0/
54.206.131.210 /Satoshi:25.0.0/
54.216.5.83 /Satoshi:25.0.0/
54.229.44.111 /Satoshi:25.0.0/
54.233.210.226 /Satoshi:25.0.0/
54.247.84.0 /Satoshi:25.0.0/
54.74.108.181 /Satoshi:25.0.0/
54.76.121.244 /Satoshi:25.0.0/
54.94.111.3 /Satoshi:25.0.0/
5.75.208.44 /Satoshi:25.1.0/
5.75.211.65 /Satoshi:25.1.0/
5.75.216.30 /Satoshi:25.1.0/
5.75.216.9 /Satoshi:25.1.0/
64.225.91.214 /Satoshi:25.1.0/
65.109.240.43 /Satoshi:25.1.0/
65.109.241.231 /Satoshi:25.1.0/
65.1.246.252 /Satoshi:25.0.0/
68.183.244.12 /Satoshi:25.1.0/
78.46.182.244 /Satoshi:25.1.0/
78.47.106.127 /Satoshi:25.1.0/
78.47.115.193 /Satoshi:25.1.0/
78.47.122.104 /Satoshi:25.1.0/
78.47.138.182 /Satoshi:25.1.0/
78.47.192.191 /Satoshi:25.1.0/
78.47.200.115 /Satoshi:25.1.0/
# Hetzner 
95.216.178.56 /Satoshi:25.1.0/
95.216.179.215 /Satoshi:25.1.0/
95.217.240.155 /Satoshi:25.1.0/
95.217.241.15 /Satoshi:25.1.0/
95.217.244.33 /Satoshi:25.1.0/
95.217.245.232 /Satoshi:25.1.0/
95.217.26.104 /Satoshi:25.1.0/
95.217.27.180 /Satoshi:25.1.0/
95.217.27.248 /Satoshi:25.1.0/
95.217.27.45 /Satoshi:25.1.0/
95.217.28.91 /Satoshi:25.1.0/
95.217.30.158 /Satoshi:25.1.0/
98.82.198.99 /Satoshi:25.0.0/
99.80.176.204 /Satoshi:25.0.0/
```

The connections are kicked by Bitcoin Core nodes with the reason: `wtxidrelay received after verack, disconnecting peer`:

![image|690x134](upload://yzCCrODvkvdCcskchmyzA001V2a.png)

Would be interesting to know when these came first online.

-------------------------

b10c | 2025-10-13 19:30:11 UTC | #2

The first occurrence of `wtxidrelay received after verack, disconnecting peer` I could find in my debug logs was on 2025-01-08 at around 11am UTC.

-------------------------

b10c | 2025-10-14 06:22:20 UTC | #3

@darosior mentions these in https://antoinep.com/posts/misbehaving_nodes/

> A couple days later, Eric comes back with another oddity. This time, he notices a bunch of nodes that don’t honour the `version` message’s relay flag. The `relay` flag instructs a node whether it should announce transactions to the sender of the `version` message. Not respecting this flag is a protocol violation and will result in a disconnection, in Bitcoin Core or Libbitcoin alike. In Eric’s experiment Libbitcoin would always set `relay` to `false` and yet those peers would still announce it transactions. All of the misbehaving peers were Bitcoin Core version 25.0 or 25.1 (but never 25.2!). Again, weird. The announced transactions traffic appeared to be organic, it wasn’t someone trying to exploit something.
> In both cases, these are nodes that are misbehaving but don’t appear to be particularly malicious. In both cases, the malicious nodes claim to be some outdated Bitcoin Core version, and in at least one of these cases we know it’s not true (Bitcoin Core will always honour the `relay` flag). Was it some script kiddy who modified a Bitcoin Core client without knowing what he’s doing? That seems highly unlikely as that’s 4 different versions and **hundreds** of nodes in total. Some proxy spoofing the `version` message of a Bitcoin Core node? For what purpose?

-------------------------

b10c | 2026-10-19 14:42:06 UTC | #4

These also set their IP in the version message where we'd expect to see our IP the peer sees us as (e.g. `35.242.187.91` sets `35.242.187.91:8333`).

I randomly sampled peers and found these:

```
78.47.192.191:8333 (78.47.0.0/16) sees us as 78.47.192.191:8333
3.126.112.133:8333 (3.126.0.0/16) sees us as 3.126.112.133:8333
52.56.64.87:8333 (52.56.0.0/16) sees us as 52.56.64.87:8333 
13.42.157.173:8333 (13.42.0.0/16) sees us as 13.42.157.173:8333
34.91.195.229:8333 (34.91.0.0/16) sees us as 34.91.195.229:8333
34.65.153.231:8333 (34.65.0.0/16) sees us as 34.65.153.231:8333
35.187.203.217:8333 (35.187.0.0/16) sees us as 35.187.203.217:8333
54.229.44.111:8333 (54.229.0.0/16) sees us as 54.229.44.111:833
35.242.187.91:8333 (35.242.0.0/16) sees us as 35.242.187.91:8333
```

there are likely more.

-------------------------

stratospher | 2026-10-19 20:45:37 UTC | #5

ooh looks like these peers are really all running the same custom software with not compatible p2p protocol (they claim 70016 in version message but behaves like 70015).

I tested them a bit:
1. since they're lying to us about our ip address, I lied to them about their ip address :)
    - they then sent their version message with `addrMe`(ip address peer thinks I am) with the ip address I had faked.
2. It claims protocol 70016 but can't negotiate `wtxidrelay` or `addrv2` properly. so core always ends up disconnecting it (or) they go silent.
3. when I tried with protocol 70015, it could reply to `getaddr`, `inv`, `getheaders`, `getdata` and even support bloom filters. they sent transaction `invs` at about 3 per second, even when we set relay=0.

-------------------------

stratospher | 2026-10-19 22:14:49 UTC | #6

of the 587 peers I checked (not exhaustive, there may be more), there were only 54 distinct getaddr responses. peers in the same group return the same ~1000 addresses with the same timestamps, differing by only 1–2 entries, while different groups share almost nothing. So the 587 IPs are most likely just 54 nodes reachable through roughly 4–25 IPs.

-------------------------

stratospher | 2026-11-04 23:24:13 UTC | #7

getting them from DNS seeds as well.

-------------------------

