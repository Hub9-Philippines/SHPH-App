export function errorHandler(error, req, res, next) {
    console.error(error);
    const status = error?.status ?? 500;
    const message = error?.message ?? 'Internal server error';
    res.status(status).json({ error: message });
}
