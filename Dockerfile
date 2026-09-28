FROM ubuntu:22.04

LABEL maintainer="dev-team"
LABEL description="Full-stack Dev Environment: Redis, Kafka, RabbitMQ, PostgreSQL, MySQL SDKs & Tools"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 1. 安装基础工具、系统编译链、中间件及数据库系统客户端
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    libffi-dev \
    # 消息队列底层库与客户端
    librdkafka-dev \
    redis-tools \
    kcat \
    amqp-tools \
    # 数据库底层驱动头文件与命令行工具
    postgresql-client \
    libpq-dev \
    default-mysql-client \
    default-libmysqlclient-dev \
    # 常用网络与排障工具
    net-tools \
    iputils-ping \
    dnsutils \
    jq \
    # Python 运行时及头文件
    python3 \
    python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 Go 开发环境 (预置 Go 1.22，可选)
ENV GOLANG_VERSION=1.22.4
RUN curl -fsSL https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin

# 3. 升级 pip 并集中安装 Python SDK 与核心库
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir \
    # --- 网络通信与常用基础库 ---
    requests \
    httpx[http2] \
    aiohttp \
    urllib3 \
    certifi \
    pydantic \
    pydantic-settings \
    python-dotenv \
    pyyaml \
    loguru \
    tenacity \
    python-dateutil \
    # --- 数据处理 ---
    pandas \
    numpy \
    openpyxl \
    # --- 中间件 SDK ---
    redis \
    hiredis \
    confluent-kafka \
    kafka-python-ng \
    pika \
    aio-pika \
    # --- 数据库 SDK 与 ORM ---
    psycopg2-binary \
    asyncpg \
    pymysql \
    mysqlclient \
    cryptography \
    SQLAlchemy \
    alembic

# 4. 预缓存常用 Go SDK (如无需 Go 可删除本段以减小体积)
WORKDIR /go/cache-prep
RUN go mod init prep && \
    go get github.com/redis/go-redis/v9 && \
    go get github.com/rabbitmq/amqp091-go && \
    go get github.com/segmentio/kafka-go && \
    go get github.com/confluentinc/confluent-kafka-go/v2/kafka && \
    go get github.com/jackc/pgx/v5 && \
    go get github.com/go-sql-driver/mysql && \
    go get gorm.io/gorm && \
    rm -rf /go/cache-prep

# 5. 工作目录配置
WORKDIR /workspace

CMD ["/bin/bash"]
