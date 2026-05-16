#!/bin/sh

# Copy Fail mitigation
echo "Applying the Copy Fail mitigation..."
echo "install algif_aead /bin/false" | sudo tee /etc/modprobe.d/llms-copy-fail-mitigation.conf > /dev/null
sudo rmmod algif_aead 2> /dev/null
if grep -qE '^algif_aead ' /proc/modules; then
    echo "WARNING: Unfortunately, applying the mitigation requires a restart."
fi

# Dirty Frag / Fragnesia mitigation
echo "Applying the Dirty Frag / Fragnesia mitigation..."
echo "install esp4 /bin/false" | sudo tee /etc/modprobe.d/llms-dirty-frag-mitigation.conf > /dev/null
echo "install esp6 /bin/false" | sudo tee -a /etc/modprobe.d/llms-dirty-frag-mitigation.conf > /dev/null
echo "install rxrpc /bin/false" | sudo tee -a /etc/modprobe.d/llms-dirty-frag-mitigation.conf > /dev/null
sudo update-initramfs -u -k all
sudo rmmod esp4 esp6 rxrpc 2>/dev/null
if grep -qE '^(esp4|esp6|rxrpc) ' /proc/modules; then
    echo "WARNING: Unfortunately, applying the mitigation requires a restart."
fi

# ssh-keysign-pwn mitigation
echo "Applying the ssh-keysign-pwn mitigation..."
sudo sysctl -w "kernel.yama.ptrace_scope=2" > /dev/null
echo "kernel.yama.ptrace_scope = 2" | sudo tee /etc/sysctl.d/99-llms-ssh-keysign-pwn-mitigation.conf > /dev/null

echo "All done."
