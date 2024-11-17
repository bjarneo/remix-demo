# builder stage
FROM node:20-alpine as builder

WORKDIR /app

COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build

# production stage
FROM node:20-alpine

WORKDIR /app

RUN addgroup -g 1001 -S nonrootgroup && adduser -u 1001 -S nonroot -G nonrootgroup

COPY --from=builder /app/build ./build
COPY --from=builder /app/package*.json ./
RUN npm ci --only=production
ENV NODE_ENV production

ENV PORT 3000
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1

USER nonroot

CMD ["npm", "start"]

