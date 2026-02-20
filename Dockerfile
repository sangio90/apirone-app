# Base JDK 17 full (ARM64)
FROM eclipse-temurin:17-jdk

# Install dependencies
RUN apt-get update && \
    apt-get install -y unzip curl git lsof && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-arm64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Workdir
WORKDIR /app

# Download CommandBox light 6.2.1
RUN curl -Lo /opt/commandbox.jar https://downloads.ortussolutions.com/ortussolutions/commandbox/6.2.1/box.jar

# Symlink box
RUN ln -s /opt/commandbox.jar /usr/local/bin/box

# Copy Lucee Debugger
COPY extras/luceedebug.jar /app/extras/luceedebug.jar

# Expose ports
EXPOSE 8081 10000 9999
ENV CommandBox_home=/app/.CommandBox

RUN java -jar /opt/commandbox.jar install
RUN alias box='java -jar /opt/commandbox.jar'

COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

# Start CommandBox server in foreground with Lucee Debug
#CMD ["java","-jar","/opt/commandbox-light.jar","server","start","--nogui","--foreground","-jvm.args=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:9999","-jvm.args=-javaagent:extras/luceedebug.jar=jdwpHost=localhost,jdwpPort=9999,debugHost=0.0.0.0,debugPort=10000,jarPath=extras/luceedebug.jar","-jvm.heapSize=4096","-jvm.minHeapSize=1024"]


