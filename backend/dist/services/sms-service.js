import crypto from 'node:crypto';
export class SmsService {
    static async sendOtp(phone, code) {
        const provider = (process.env.SMS_PROVIDER ?? 'test').toLowerCase();
        if (provider === 'test') {
            if (process.env.NODE_ENV === 'production') {
                throw new Error('SMS_PROVIDER must be configured in production');
            }
            console.info(`[development SMS] OTP requested for ${phone}; use SMS_TEST_OTP`);
            return;
        }
        if (provider !== 'twilio') {
            throw new Error(`Unsupported SMS_PROVIDER: ${provider}`);
        }
        const accountSid = requireEnv('TWILIO_ACCOUNT_SID');
        const authToken = requireEnv('TWILIO_AUTH_TOKEN');
        const from = process.env.TWILIO_FROM_NUMBER;
        const messagingServiceSid = process.env.TWILIO_MESSAGING_SERVICE_SID;
        if (!from && !messagingServiceSid) {
            throw new Error('TWILIO_FROM_NUMBER or TWILIO_MESSAGING_SERVICE_SID is required');
        }
        const body = new URLSearchParams({
            To: phone,
            Body: `${process.env.SMS_APP_NAME ?? 'SerbisyoHub PH'} verification code: ${code}`,
        });
        if (messagingServiceSid)
            body.set('MessagingServiceSid', messagingServiceSid);
        else
            body.set('From', from);
        const response = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`, {
            method: 'POST',
            headers: {
                Authorization: `Basic ${Buffer.from(`${accountSid}:${authToken}`).toString('base64')}`,
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body,
        });
        if (!response.ok) {
            const requestId = crypto.randomUUID();
            console.error(`Twilio SMS request ${requestId} failed with status ${response.status}`);
            throw new Error(`SMS provider rejected the request (${requestId})`);
        }
    }
}
function requireEnv(name) {
    const value = process.env[name];
    if (!value)
        throw new Error(`${name} is required`);
    return value;
}
