FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y wget && \
    apt-get clean all

# Create dir for storing am62 stuff
ENV DEV_DIR_ROOT=/opt
ENV DEV_DIR=${DEV_DIR_ROOT}/am62
RUN mkdir -p ${DEV_DIR}

# Store some useful docs
ENV DOC_DIR=${DEV_DIR}/docs
RUN mkdir -p ${DOC_DIR}
RUN wget https://www.ti.com/lit/ug/spruj40c/spruj40c.pdf -O ${DOC_DIR}/am62x_sk_evm_users_guide.pdf
RUN echo "https://dev.ti.com/tirex/explore/node?node=A__AdoyIZ2jtLBUfHZNVmgFBQ__am62x-devtools__FUz-xrs__LATEST&search=am62x" > ${DOC_DIR}/am62x_sk_quickstart_url.txt
RUN echo "https://www.ti.com/tool/PROCESSOR-SDK-AM62X" > ${DOC_DIR}/am62x_sk_dev_tools_url.txt

# Install linux SDK
RUN cd ${DEV_DIR} \
    && wget --no-verbose --show-progress --progress=dot -e dotbytes=125m \
       https://dr-download.ti.com/software-development/software-development-kit-sdk/MD-PvdSyIiioq/09.00.00.03/ti-processor-sdk-linux-am62xx-evm-09.00.00.03-Linux-x86-Install.bin \
    && chmod +x ./ti-processor-sdk-linux-am62xx-evm-09.00.00.03-Linux-x86-Install.bin

ARG USER
ARG GROUP
ARG USER_ID
ARG GROUP_ID

RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get clean all

RUN echo "USER=${USER} GROUP=${GROUP} USER_ID=${USER_ID} GROUP_ID=${GROUP_ID}"
RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    echo "USER_ID=${USER_ID} GROUP_ID=${GROUP_ID}" \
    && groupadd -g ${GROUP_ID} ${GROUP} \
    && useradd -l -m -u ${USER_ID} -g ${GROUP_ID} -G plugdev,dialout,sudo ${USER} \
;fi

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Give USER control of DEV_DIR_ROOT directory
RUN chown -R ${USER}:${GROUP} ${DEV_DIR_ROOT}

# Install packages needed by setup script (plus vim)
RUN apt-get update \
    && apt-get install -y \
       iproute2 \
       lsb-release \
       usbutils \
       vim \
    && apt-get clean all

USER ${USER}

RUN ${DEV_DIR}/ti-processor-sdk-linux-am62xx-evm-09.00.00.03-Linux-x86-Install.bin --prefix ${DEV_DIR}/ti-processor-sdk-linux-am62xx-evm-09.00.00.03 --unattendedmodeui none
RUN rm ${DEV_DIR}/ti-processor-sdk-linux-am62xx-evm-09.00.00.03-Linux-x86-Install.bin
