FROM alpine:3.5

COPY script.sh .

RUN chmod u+x script.sh

CMD ["./script.sh"]