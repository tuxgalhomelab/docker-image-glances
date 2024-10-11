# syntax=docker/dockerfile:1

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG} AS with-scripts

COPY scripts/start-glances.sh scripts/install-glances.sh /scripts/

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID
ARG GLANCES_VERSION

# hadolint ignore=SC3040
RUN --mount=type=bind,target=/scripts,from=with-scripts,source=/scripts \
    set -E -e -o pipefail \
    && export HOMELAB_VERBOSE=y \
    # Install build dependencies. \
    && homelab install util-linux git \
    # Create the user and the group. \
    && homelab add-user \
        ${USER_NAME:?} \
        ${USER_ID:?} \
        ${GROUP_NAME:?} \
        ${GROUP_ID:?} \
        --create-home-dir \
    # Download and install the release. \
    && homelab install-git-repo \
        https://github.com/nicolargo/glances \
        ${GLANCES_VERSION:?} \
        glances \
        glances-${GLANCES_VERSION:?} \
        ${USER_NAME:?} \
        ${GROUP_NAME:?} \
    && mkdir -p /data/glances/config \
    && cp /opt/glances/conf/glances.conf /data/glances/config/glances.conf \
    && chown -R ${USER_NAME:?}:${GROUP_NAME:?} /data/glances/config \
    && su --login --shell /bin/bash --command "/scripts/install-glances.sh" ${USER_NAME:?} \
    # Copy the start-glances.sh script. \
    && cp /scripts/start-glances.sh /opt/glances/ \
    && ln -sf /opt/glances/start-glances.sh /opt/bin/start-glances \
    # Clean up. \
    && homelab remove util-linux git \
    && homelab cleanup

EXPOSE 61208

HEALTHCHECK \
    --start-period=15s --interval=30s --timeout=3s \
    CMD homelab healthcheck-service http://localhost:61208/api/4/status

ENV USER=${USER_NAME}
USER ${USER_NAME}:${GROUP_NAME}
WORKDIR /home/${USER_NAME}

CMD ["start-glances"]
STOPSIGNAL SIGINT
