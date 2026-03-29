const checkRole = (rolesAutorises) => {
    return (req, res, next) => {
        // On récupère le rôle passé dans les headers
        const userRole = req.headers['role']; 

        if (!userRole || !rolesAutorises.includes(userRole)) {
            return res.status(403).json({ 
                message: `Accès refusé. Rôle [${userRole || 'NON_DEFINI'}] non autorisé.` 
            });
        }
        
        next();
    };
};

module.exports = checkRole;