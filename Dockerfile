#
# Aerospike Server Dockerfile
#
# http://github.com/aerospike/aerospike-server.docker
#

FROM debian:7

ENV AEROSPIKE_VERSION 3.7.4
ENV AEROSPIKE_SHA256 9cb027032422c35fcd80ff3da5b6fe7d0a3e704d50a055c5490f5028787d4ed8       

# Install Aerospike
RUN \
  apt-get update -y \
  && apt-get install -y wget logrotate ca-certificates \
  && wget "https://www.aerospike.com/artifacts/aerospike-server-community/${AEROSPIKE_VERSION}/aerospike-server-community-${AEROSPIKE_VERSION}-debian7.tgz" -O aerospike-server.tgz \
  && echo "$AEROSPIKE_SHA256 *aerospike-server.tgz" | sha256sum -c - \
  && mkdir aerospike \
  && tar xzf aerospike-server.tgz --strip-components=1 -C aerospike \
  && dpkg -i aerospike/aerospike-server-*.deb \
  && apt-get purge -y --auto-remove wget ca-certificates \
  && rm -rf aerospike-server.tgz aerospike /var/lib/apt/lists/*

# Add the Aerospike configuration specific to this dockerfile
COPY aerospike.conf /etc/aerospike/aerospike.conf
COPY entrypoint.sh /entrypoint.sh
# Mount the Aerospike data directory
VOLUME ["/opt/aerospike/data"]
# VOLUME ["/etc/aerospike/"]


# Expose Aerospike ports
#
#   3000 – service port, for client connections
#   3001 – fabric port, for cluster communication
#   3002 – mesh port, for cluster heartbeat
#   3003 – info port
#
EXPOSE 3000 3001 3002 3003

# Execute the run script in foreground mode
ENTRYPOINT ["/entrypoint.sh"]
CMD ["asd"]
