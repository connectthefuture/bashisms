function upload_to_s3() {
  if [[ -z "${S3_UPLOADER_AWS_SECRET_KEY}" ]] ; then
    echo "Need s3 creds..."
    return 1
  fi
  if [[ -z "${S3_UPLOADER_AWS_ACCESS_KEY}" ]] ; then
    echo "Need s3 creds..."
    return 1
  fi
  if [[ ! -a "${1}" ]] ; then
    echo "Need a file"
    return 1
  fi

  bucket=onsi-public
  resource="/${bucket}/${1}"
  contentType="binary/octet-stream"
  dateValue=`date -u "+%a, %d %b %Y %H:%M:%S GMT"`
  stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
  signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${S3_UPLOADER_AWS_SECRET_KEY} -binary | base64`

  echo "Uploading $1..."
  curl -X PUT -T "${1}" \
    -H "Host: ${bucket}.s3.amazonaws.com" \
    -H "Date: ${dateValue}" \
    -H "Content-Type: ${contentType}" \
    -H "Authorization: AWS ${S3_UPLOADER_AWS_ACCESS_KEY}:${signature}" \
    https://${bucket}.s3.amazonaws.com/${1}
  echo "http://onsi-public.s3.amazonaws.com/$1"
}
