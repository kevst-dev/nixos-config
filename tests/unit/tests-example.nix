{
  name = "Two machines ping each other";

  nodes = {
    # These configs do not add anything to the default system setup
    machine1 = _: {};
    machine2 = _: {};
  };

  # Note that machine1 and machine2 are now available as
  # Python objects and also as hostnames in the virtual network
  testScript = ''
    print("🚀 Starting test...")

    print("⏰ Starting network services...")
    machine1.systemctl("start network-online.target")
    machine2.systemctl("start network-online.target")

    print("⏳ Waiting for network to be online...")
    machine1.wait_for_unit("network-online.target")
    machine2.wait_for_unit("network-online.target")

    print("🌐 Testing ping from machine1 to machine2...")
    machine1.succeed("ping -c 1 machine2")

    print("🌐 Testing ping from machine2 to machine1...")
    machine2.succeed("ping -c 1 machine1")

    print("✅ Test completed successfully!")
  '';
}
