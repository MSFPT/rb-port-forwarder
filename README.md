# rb-port-forwarder

**Port Forwarding using Ruby**

port-forward forwards(obviously) an incomming TCP connection on a specific port to another local/remote port

**Note:** Type 'exit' or 'quit' to exit the script safely (wont exit your netcat session)

Support all OS's if ruby installed

<br>

## Clone from GitHub

```bash
git clone https://github.com/msfpt/rb-port-forwarder
```

```bash
cd rb-port-forwarder
```

#### if was unix

```bash
chmod +x *
```

<br>

## Usage
```bash
ruby port-forwarder.rb -lp [local-port] -f [forward-host]:[forward-port]
```

<br>

## Example:
```bash
ruby port-forwarder.rb --local-port 80 --forward 192.168.0.236:6060
```

 OR

```bash
ruby port-forwarder.rb -lp 80 -f 192.168.0.236:6060
```

<br>

## Args

   |   argument    |     default     | utilization |
   | ------------- | --------------- | ----------- |
   | `--local-port` or `-lp` |  | required |
   | `--forward` or `f` | [your-ip]:[asks] | optional |
   | `--help` or `-h` |  | optional |
