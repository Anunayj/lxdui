# docker run -it -p 15151:15151 -v /var/snap/lxd/common/lxd/unix.socket:/var/snap/lxd/common/lxd/unix.socket lxdui

# docker run -it -p 15151:15151 -v /var/snap/lxd/common/lxd/unix.socket:/var/snap/lxd/common/lxd/unix.socket phenonymous/lxdui
FROM python:3.8-alpine AS BASE
RUN apk add libffi-dev openssl-dev 

FROM BASE as BUILDER

RUN mkdir install
WORKDIR /app
RUN apk add build-base cargo
COPY requirements.txt /app/requirements.txt
RUN pip install --target=/install -r /app/requirements.txt
COPY run.py /app/run.py
COPY app/ /app/app
COPY conf/ /app/conf
COPY logs/ /app/logs

FROM BASE
COPY --from=BUILDER /install /usr
COPY --from=BUILDER /app /app
EXPOSE 15151
WORKDIR /app
ENV PYTHONPATH=/usr
ENTRYPOINT ["python", "run.py", "start"]
