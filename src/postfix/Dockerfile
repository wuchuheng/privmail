FROM alpine:3.14


RUN apk add --no-cache postfix shadow

RUN if ! getent group postdrop > /dev/null; then \
    addgroup -S postdrop; \
    echo "Group postdrop created."; \
fi

RUN if ! getent user postfix > /dev/null; then \
    adduser -S postfix -G postdrop; \
    echo "User postfix created."; \
fi

EXPOSE 25 587