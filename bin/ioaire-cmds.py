from ioaire import commands as cmds
# print(f'{cmds.ifconfig().decode("UTF8")}')

foo = cmds.debchk(['iperf', 'flex', 'bison', 'fff' ])

print(f'foo {foo}')
