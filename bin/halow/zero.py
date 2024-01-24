from zeroconf import ServiceBrowser, ServiceListener, Zeroconf


class MyListener(ServiceListener):

    def update_service(self, zc: Zeroconf, type_: str, name: str) -> None:
        print(f"Service {name} updated")

    def remove_service(self, zc: Zeroconf, type_: str, name: str) -> None:
        print(f"Service {name} removed")

    def add_service(self, zc: Zeroconf, type_: str, name: str) -> None:
        info = zc.get_service_info(type_, name)
        print(f"Service {name} added, service info:")
        print(f"\t\ttype: {info.type}")
        print(f"\t\tport: {info.port}")
        print(f"\t\taddresses: {info.addresses}")
        print(f"\t\tserver: {info.server}")


zeroconf = Zeroconf()
listener = MyListener()
browser = ServiceBrowser(zeroconf, "_workstation._tcp.local.", listener)
try:
    input("Press enter to exit...\n\n")
finally:
    zeroconf.close()

