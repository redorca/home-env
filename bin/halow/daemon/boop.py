import socket

skt = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

skt.connect(('flight', 5000))
skt.send(b'abcd')
bloop = skt.recv(55)
print(f'bloop: {bloop}')

