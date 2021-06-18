##
# Set our base for lal others to inherit from
#
FROM debian:buster-slim AS base



##
# The build layer where we'll download and verify things
#
FROM base AS build

WORKDIR /workdir

# hadolint ignore=DL3015
RUN apt-get update -y \
  && apt-get install -y \
    ca-certificates=20200601~deb10u2 \
    libdigest-sha-perl=6.02-1+b1 \
    wget=1.20.1-1.1

ARG ARCH=x86_64
ARG CHECKSUM=ca50936299e2c5a66b954c266dcaaeef9e91b2f5307069b9894048acf3eb5751
ARG PLATFORM=linux-gnu
ARG VERSION=0.18.1

# Set pipefail to make sure we catch if any of the steps fail, download
#  the release, validate the checksum, and finally extract + rename it
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget --progress=dot:giga https://download.litecoin.org/litecoin-${VERSION}/linux/litecoin-${VERSION}-${ARCH}-${PLATFORM}.tar.gz \
  && echo "${CHECKSUM}  litecoin-${VERSION}-${ARCH}-${PLATFORM}.tar.gz" | shasum --check \
  && tar -xaf litecoin-${VERSION}-${ARCH}-${PLATFORM}.tar.gz \
  && mv litecoin-${VERSION} litecoin-release



##
# The final layer which we'll keep pristine and publish
#
FROM base AS final

# Add a non-system user that we can run as, this is good security hygiene!
#  So that if a container is exploited/escaped, the user is >= 1000 and
#  less likely to exist on the host system nor be a privileged system user
RUN groupadd --gid 1111 litecoin \
  && useradd --create-home --uid 1111 --gid 1111 litecoin \
  && mkdir --parents /home/litecoin/.litecoin \
  && chown :1111 /home/litecoin/.litecoin \
  && chmod 775 /home/litecoin/.litecoin \
  && chmod g+s /home/litecoin/.litecoin

COPY --from=build /workdir/litecoin-release/bin /usr/local/bin

VOLUME ["/home/litecoin/.litecoin"]

EXPOSE 9332 9333 19332 19335 19443 19444

USER litecoin

# Any args/input passed to the container will go to this entrypoint,
#  if you'd like to override this entrypoint you can do so manually
#  and change it to whatever you like
ENTRYPOINT ["/usr/local/bin/litecoind"]
