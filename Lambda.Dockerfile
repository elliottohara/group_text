# Build the stuff we need to compile nicely for aws lambda first so it can be cached
FROM lambci/lambda:build-python3.7 AS base-build

FROM base-build as lambda-build

ENV LC_ALL=en_US.UTF-8

WORKDIR /lambda

RUN pip3 install --upgrade pip

COPY ./requirements.txt .

RUN pip3 install -t . -r ./requirements.txt

COPY ./src .

RUN zip -r9 lambda.zip .
