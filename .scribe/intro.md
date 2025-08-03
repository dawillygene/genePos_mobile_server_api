# Introduction

Multi-tenant Point of Sale API with shop management and role-based access control

<aside>
    <strong>Base URL</strong>: <code>https://genepos.dawillygene.com</code>
</aside>

    Welcome to the GenePos API documentation! This API provides comprehensive Point of Sale functionality with multi-tenant shop management.

    ## Features
    - **Multi-tenant Architecture**: Complete shop isolation with role-based access control
    - **Authentication**: Google OAuth and traditional email/password login
    - **Shop Management**: Create and manage shops, team members, and settings
    - **Product Management**: CRUD operations for products with shop isolation
    - **Sales Management**: Process sales, manage transactions, and generate reports
    - **Team Management**: Add sales persons, manage permissions, and track activity

    ## Authentication
    Most endpoints require authentication. You can authenticate using:
    1. **Google OAuth**: Get a token via `/auth/google`
    2. **Email/Password**: Register via `/auth/register` or login via `/auth/login`

    Include the token in the Authorization header: `Bearer {your-token}`

    <aside>As you scroll, you'll see code examples for working with the API in different programming languages in the dark area to the right.</aside>

