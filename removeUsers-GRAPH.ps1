Import-Module Microsoft.Graph

Connect-MgGraph

$emails = @(
    "Emily.Armitage@birmingham-rep.co.uk",
    "David.Thompson@birmingham-rep.co.uk",
    "Benjamin.Akyen@birmingham-rep.co.uk",
    "Baljinder.Singh@birmingham-rep.co.uk",
    "Libby.Glass@birmingham-rep.co.uk",
    "Garfield.Wright@birmingham-rep.co.uk",
    "Braian.Plisiuk@birmingham-rep.co.uk",
    "Richard.Jordan@birmingham-rep.co.uk",
    "Bethany.Steventon-Crinks@birmingham-rep.co.uk",
    "Issac.Vivan@birmingham-rep.co.uk",
    "Cecile.Pauty@birmingham-rep.co.uk",
    "Ilana.Gelbart@birmingham-rep.co.uk",
    "Samina.Beckford@birmingham-rep.co.uk",
    "Anastasija.Koneva@birmingham-rep.co.uk",
    "Laura.Dredger@birmingham-rep.co.uk",
    "Flora.Sawyer@birmingham-rep.co.uk",
    "Prema.Ale@birmingham-rep.co.uk",
    "Michael.Peters@birmingham-rep.co.uk",
    "Martin.Hill@birmingham-rep.co.uk",
    "Emily.Davis@birmingham-rep.co.uk",
    "Gurpreet.Kaur@birmingham-rep.co.uk",
    "vdi1@birmingham-rep.co.uk",
    "Akorede.Osisanya@birmingham-rep.co.uk",
    "Donna.Nolan@birmingham-rep.co.uk",
    "Brandon.Hinds@birmingham-rep.co.uk",
    "Joe.Kennard@birmingham-rep.co.uk",
    "Sam.Friel@uniquevenuesbirmingham.com",
    "Natalie.Hart@birmingham-rep.co.uk",
    "Somayya.Sheikh@birmingham-rep.co.uk"
)


foreach ($email in $emails) {
    try {
        $user = Get-MgUser -Filter "mail eq '$email'"
        if ($user) {
            Remove-MgUser -UserId $user.Id -Confirm:$false
            Write-Host "User with email $email deleted successfully"
        } else {
            Write-Host "User with email $email not found"
        }
    } catch {
        Write-Host "Failed to delete user with email $email. Error: $_"
    }
}

Disconnect-MgGraph