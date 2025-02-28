#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <security-group-id>"
    exit 1
fi

SECURITY_GROUP_ID=$1

aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --ip-permissions '[
{"IpProtocol": "icmp", "FromPort": 8, "ToPort": -1, "IpRanges": [{"CidrIp": "10.0.0.0/8"}]},
{"IpProtocol": "tcp", "FromPort": 445, "ToPort": 445, "IpRanges": [{"CidrIp": "10.0.111.130/32"}]},
{"IpProtocol": "tcp", "FromPort": 4422, "ToPort": 4422, "IpRanges": [{"CidrIp": "10.0.111.130/32"}]},
{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "10.0.111.0/24"}]},
{"IpProtocol": "tcp", "FromPort": 3389, "ToPort": 3389, "IpRanges": [{"CidrIp": "10.0.114.0/24"}]},
{"IpProtocol": "tcp", "FromPort": 8081, "ToPort": 8081, "IpRanges": [{"CidrIp": "10.0.23.14/32"}]},
{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "10.0.117.0/24"}]},
{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "10.1.111.130/32"}]},
{"IpProtocol": "tcp", "FromPort": 53, "ToPort": 53, "IpRanges": [{"CidrIp": "10.0.26.77/32"}]},
{"IpProtocol": "tcp", "FromPort": 0, "ToPort": 65535, "IpRanges": [{"CidrIp": "10.0.23.105/32"}]},
{"IpProtocol": "tcp", "FromPort": 445, "ToPort": 445, "IpRanges": [{"CidrIp": "10.0.111.131/32"}]},
{"IpProtocol": "tcp", "FromPort": 3389, "ToPort": 3389, "IpRanges": [{"CidrIp": "10.0.113.0/24"}]},
{"IpProtocol": "tcp", "FromPort": 123, "ToPort": 123, "IpRanges": [{"CidrIp": "10.0.43.21/32"}]},
{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "10.0.111.130/32"}]},
{"IpProtocol": "tcp", "FromPort": 135, "ToPort": 135, "IpRanges": [{"CidrIp": "10.0.111.131/32"}]},
{"IpProtocol": "tcp", "FromPort": 389, "ToPort": 389, "IpRanges": [{"CidrIp": "10.0.26.88/32"}]},
{"IpProtocol": "tcp", "FromPort": 389, "ToPort": 389, "IpRanges": [{"CidrIp": "10.1.26.77/32"}]},
{"IpProtocol": "tcp", "FromPort": 389, "ToPort": 389, "IpRanges": [{"CidrIp": "10.0.26.77/32"}]},
{"IpProtocol": "tcp", "FromPort": 53, "ToPort": 53, "IpRanges": [{"CidrIp": "10.1.26.77/32"}]},
{"IpProtocol": "tcp", "FromPort": 9182, "ToPort": 9182, "IpRanges": [{"CidrIp": "10.224.20.128/26"}]},
{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "10.0.23.245/32"}]},
{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "10.0.114.0/24"}]},
{"IpProtocol": "tcp", "FromPort": 3389, "ToPort": 3389, "IpRanges": [{"CidrIp": "10.0.111.0/24"}]},
{"IpProtocol": "tcp", "FromPort": 9100, "ToPort": 9100, "IpRanges": [{"CidrIp": "10.224.20.128/26"}]},
{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "10.0.113.0/24"}]},
{"IpProtocol": "tcp", "FromPort": 0, "ToPort": 65535, "IpRanges": [{"CidrIp": "10.0.23.16/32"}]},
{"IpProtocol": "tcp", "FromPort": 135, "ToPort": 135, "IpRanges": [{"CidrIp": "10.0.111.130/32"}]},
{"IpProtocol": "tcp", "FromPort": 53, "ToPort": 53, "IpRanges": [{"CidrIp": "10.0.26.88/32"}]},
{"IpProtocol": "tcp", "FromPort": 4422, "ToPort": 4422, "IpRanges": [{"CidrIp": "10.0.111.131/32"}]},
{"IpProtocol": "udp", "FromPort": 123, "ToPort": 123, "IpRanges": [{"CidrIp": "10.0.43.21/32"}]},
{"IpProtocol": "udp", "FromPort": 53, "ToPort": 53, "IpRanges": [{"CidrIp": "10.0.26.77/32"}]},
{"IpProtocol": "udp", "FromPort": 445, "ToPort": 445, "IpRanges": [{"CidrIp": "10.0.111.130/32"}]},
{"IpProtocol": "udp", "FromPort": 135, "ToPort": 135, "IpRanges": [{"CidrIp": "10.0.111.130/32"}]},
{"IpProtocol": "udp", "FromPort": 0, "ToPort": 65535, "IpRanges": [{"CidrIp": "10.0.23.16/32"}]},
{"IpProtocol": "udp", "FromPort": 135, "ToPort": 135, "IpRanges": [{"CidrIp": "10.0.111.131/32"}]},
{"IpProtocol": "udp", "FromPort": 0, "ToPort": 65535, "IpRanges": [{"CidrIp": "10.0.23.105/32"}]},
{"IpProtocol": "udp", "FromPort": 445, "ToPort": 445, "IpRanges": [{"CidrIp": "10.0.111.131/32"}]},
{"IpProtocol": "udp", "FromPort": 161, "ToPort": 161, "IpRanges": [{"CidrIp": "10.0.23.245/32"}]},
{"IpProtocol": "udp", "FromPort": 8081, "ToPort": 8081, "IpRanges": [{"CidrIp": "10.0.23.14/32"}]},
{"IpProtocol": "udp", "FromPort": 53, "ToPort": 53, "IpRanges": [{"CidrIp": "10.0.26.88/32"}]},
{"IpProtocol": "udp", "FromPort": 53, "ToPort": 53, "IpRanges": [{"CidrIp": "10.1.26.77/32"}]}
]'
