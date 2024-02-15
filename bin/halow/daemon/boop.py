import socket
import json

skt = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

skt.connect(('sandcube.local', 5000))
ralph = {"name":"ralph", "city":"sf"}
alph = json.dumps(ralph)
print(f'alph {alph}, type {type(alph)}')

skt.send(bytes(alph.encode('utf8')))
bloop = skt.recv(550)
# print(f'{json.dumps(bloop)}, type {type(json.dumps(bloop))}')
print(f'bloop: {bloop.decode("UTF8")}')
goof = json.loads(bloop)
print(f'new name {goof["name"]}')
