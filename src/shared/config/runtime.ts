export default {
  secrets: {
    qiniu: {
      accessKey: import.meta.env.QINIU_ACCESS_KEY,
      secretKey: import.meta.env.QINIU_SECRET_KEY,
      bucket: import.meta.env.QINIU_BUCKET,
    },
  },
};
